;***************************************************************************
;* Photo Display with stop by CTRL-C
;***************************************************************************
PHOTO_TEST:
	push	ZH
	push	ZL
	push	XH
	push	XL
	push	temp

	rcall	UARTInt_On		; 해당 함수(Service Routine) 내에서만 RX Interrupt 실행
	rcall	ADC_Init		; AD Converter 관련함수 초기화

	cli						; Disable Interrupt
	rcall	Timer0_init
	sei						; Enable Interrupt

	; 7SEG를 위한 PortC의 DDR 세팅
	ser		temp
	out		DDRC, temp

	; 4개의 7SEG를 선택하기 위한 PortG의 DDR 세팅
	ldi		temp, $0F		; 하위 4bit만 사용
	sts		DDRG, temp		; Extended I/O Port

	ldi		TESTmode, TMODE_PHOTO

	SetDigit4	17, 17, 17, 17

Check_PHOTO:
	tst		TESTmode
	breq	DONE_PHOTO
	ldi		FND_En, 0x08		; Enable을 0000 1000으로 설정
	SETXY	X, digit4			; X를 다시 digit4의 시작주소로 설정

PHOTO_Loop:
	sts		PORTG, FND_En	; PORTG에 FND_En값 저장(몇 번째 7seg를 킬 것인지 조정) 
	ld		temp, X+		; Offset 값 가져오기

	SETZ	SegData			; PM의 SegData의 시작주소를 Z 레지스터로 설정
	add		ZL, temp		; Offset만큼 주소를 더하기(즉, Z 레지스터의 커서를 이동)
	adc		ZH, r0
	
	lpm		FND_Data, Z		; 현재 Z 레지스터가 가리키고 있는 주소 안의 값을 Load
	out		PORTC, FND_Data	; Port C를 통해 출력

	DELAYMS 1
	
	// 4개의 7SEG에 대한 반복을 마치면 다시 처음 7SEG로 돌아가기 위해 shift
	lsr		FND_En			; 하나 뒤로 옮기기 위해 logistic shift right
	breq	Check_PHOTO		; 0000이 되면 다시 1000으로 SetLoop으로 돌아가기
	rjmp	PHOTO_Loop

DONE_PHOTO:
	cli

	; PORTC off
	out		PORTC, r0

	; PORTG off
	sts		PORTG, r0

	; Timer1 off
	out		TIMSK, r0

	pop		XL
	pop		XH
	pop		ZL
	pop		ZH
	pop		temp
	ret