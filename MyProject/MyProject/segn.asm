;***************************************************************************
;* SegN Display with stop by CTRL-C
;***************************************************************************
SEGN_TEST:
	push	temp

	rcall	UARTInt_On		; 해당 함수(Service Routine) 내에서만 RX Interrupt 실행
	cli						; Disable Interrupt
	rcall	ExInt_init
	rcall	Timer1_init

	; 7SEG를 위한 PortC의 DDR 세팅
	ser		temp
	out		DDRC, temp

	; 4개의 7SEG를 선택하기 위한 PortG의 DDR 세팅
	ldi		temp, $0F		; 하위 4bit만 사용
	sts		DDRG, temp		; Extended I/O Port

	ldi		TESTmode, TMODE_SEGN

	; 초기설정
	mov		GoStop, r2			; Go
	SETDigit4	0,0,0,0
	sei

Check_SEGN:
	tst		TESTmode			; 0(CTRL-C 값이 입력됨)인지 체크
	breq	DONE_SEGN			; 0일 경우 SEGN Off
	ldi		FND_En, 0x08		; Enable을 0000 1000으로 설정
	SETXY	X, digit4			; X를 다시 digit4의 시작주소로 설정

SEGN_Loop:
	sts		PORTG, FND_En	; PORTG에 FND_En값 저장(몇 번째 7seg를 킬 것인지 조정) 
	ld		temp, X+		; Offset 값 가져오기
	
	SETZ	SegData			; PM의 SegData의 시작주소를 Z 레지스터로 설정
	add		ZL, temp		; Offset만큼 주소를 더하기(즉, Z 레지스터의 커서를 이동)
	add		ZH, r0

	lpm		FND_Data, Z		; 현재 Z 레지스터가 가리키고 있는 주소 안의 값을 Load
	out		PORTC, FND_Data	; Port C를 통해 출력

	DELAYMS 1
	
	// 4개의 7SEG에 대한 반복을 마치면 다시 처음 7SEG로 돌아가기 위해 shift
	lsr		FND_En			; 하나 뒤로 옮기기 위해 logistic shift right
	breq	Check_SEGN		; 0000이 되면 다시 1000으로 SetLoop으로 돌아가기
	rjmp	SEGN_Loop
	

DONE_SEGN:
	cli
	ldi		temp, 0x00

	; External Interrupt off
	out		EIMSK, temp

	; PORTC off
	out		PORTC, temp

	; PORTG off
	sts		PORTG, temp

	; Timer1 off
	out		TIMSK, temp
	
	rcall	UARTint_off
	pop		temp
	ret

;***************************************************************************
; Initialization
; clock source : system clock
; clock value : 16MHz / 8 = 2Mhz;
; overflow interrupt freq : 100Hz
;***************************************************************************

ExInt_init:
	cli

	ldi		temp, 0x00
	sts		EICRA, temp		; 주소로 인해 in/out 명령어 불가능하므로 sts 명령어 사용

	ldi		temp, 0x0A
	out		EICRB, temp		; Switch 4, 5 falling edge

	ldi		temp, 0x30
	out		EIMSK, temp		; External Interrupt의 Mask Register 설정

	sei
	ret

Timer1_init:
	ldi		temp, 0x02		; Clock Source = 16MHz / 8
	out		TCCR1B, temp

	; 45536~65536 즉, 20000번을 통해 1/100sec 세기
	ldi		temp, HIGH(45536)		
	out		TCNT1H, temp
	ldi		temp, LOW(45536)
	out		TCNT1L, temp

	ldi		temp, 0x04		; Timer1 Overflow의 Interrupt를 Enable
	out		TIMSK, temp
	
	ret

Timer1_OVF:
	cli						; Disable Interrupt
	push	XH
	push	XL
	push	temp
	in		SREG2, SREG		; Status Register 저장
	
	; 매 인터럽트가 0.01초이므로 Time0cnt가 필요X -> 단, TCNT 16 bit 레지스터를 다시 45536으로 초기화 필요
	; 45536~65536 즉, 20000번을 통해 1/100sec 세기
	ldi		temp, HIGH(45536)		
	out		TCNT1H, temp
	ldi		temp, LOW(45536)
	out		TCNT1L, temp

UpdateTime:
	cp		GoStop, r0		; GoStop이 0이면 마지막 digit의 값을 늘리지 않음(Stop)
	breq	UpdateDone
	
	SETXY	X, digit4		; digit4의 시작주소를 X 레지스터에 저장
	
	ldi		temp, 3			; X레지스터가 가리키는 커서를 3만큼 옮겨주기 위해서
	add		XL, temp
	add		XH, r0

	ld		temp, X			; X가 가리키는 주소 안의 값(현재 digit4의 4번째 값을 가리킴)
	inc		temp
	cpi		temp, 10		; 마지막 자리가 10이 되는지 비교
	breq	Update_2
	st		X, temp			; X가 가리키는 주소에 temp 저장
	
UpdateDone:
	out		SREG, SREG2		; Status Register 복구
	pop		temp
	pop		XL
	pop		XH
	
	sei						; Enable
	reti

Update_2:
	clr		temp			; temp(digit4의 4번째 자리 초기화)
	st		X, temp

	ld		temp, -X		; digit4의 3번째 자리 값 가져오기
	inc		temp
	cpi		temp, 10		; 3번째 자리가 10이 되는지 비교
	breq	Update_1
	st		X, temp			
	rjmp	UpdateDone

Update_1:
	clr		temp			; temp(digit4의 3번째 자리 초기화)
	st		X, temp

	ld		temp, -X		; digit4의 2번째 자리 값 가져오기
	inc		temp
	cpi		temp, 10		; 2번째 자리가 10이 되는지 비교
	breq	Update_0
	st		X, temp			
	rjmp	UpdateDone

Update_0:
	clr		temp			; temp(digit4의 3번째 자리 초기화)
	st		X, temp

	ld		temp, -X		; digit4의 1번째 자리 값 가져오기
	inc		temp
	cpi		temp, 6			; 1번째 자리가 6이 되는지 비교
	breq	Update_0
	st		X, temp			
	rjmp	UpdateDone

Ext_Int4:
	
	cli							; Disable Interrupt
	push		XH
	push		XL
	push		temp
	push		r24
	push		r25
	in			SREG2, SREG		; Status Register 저장
	
	cpi			TESTmode, 0x08
	breq		Ex4_Proj
	
	SETDigit4	0,0,0,0			; 스위치 4를 누르면 00:00으로 만들기
	mov			GoStop, r0		; GoStop을 0으로 만들기(stop)
	DELAYMS		10
	rjmp		Ex4_Done

Ex4_Proj:
	// ???
		
Ex4_Done:

	out			SREG, SREG2		; Status Register 저장
	pop			r25
	pop			r24
	pop			temp
	pop			XL
	pop			XH
	sei							; Enable
	ret

Ext_Int5:

	cli							; Disable Interrupt
	push		XH
	push		XL
	push		temp
	push		r24
	push		r25
	in			SREG2, SREG		; Status Register 저장

	cpi			TESTmode, 0x08
	breq		Ex5_Proj

	com			GoStop	 		; GoStop을 반전
	DELAYMS		10
	rjmp		Ex5_Done

Ex5_Proj:
	// ???

Ex5_Done:
	out			SREG, SREG2		; Status Register 저장
	pop			r25
	pop			r24
	pop			temp
	pop			XL
	pop			XH
	sei							; Enable
	ret