;***************************************************************************
; Timer/Counter 0 initialization
; clock source : system clock
; clock value : 16MHz / 256 = 62.5Khz;
; overflow interrupt freq : 62500 / 256 = 244.14Hz
; phone.asm and photo.asm
;***************************************************************************
Timer0_init:
	ldi			temp, 0x06		; Clock Source = 16MHz / 256
	out			TCCR0, temp

	ldi			temp, 0x00		
	out			TCNT0, temp		; 0 ~ 255까지 다 사용(즉, FF -> 00으로 변할 때 Interrupt 발생)

	ldi			temp, 1			; Timer0에만 Interrupt 신호를 Enable로
	out			TIMSK, temp
	
	ret

Timer0_OVF:
	cli
	push		XH
	push		XL
	push		ZH
	push		ZL
	push		r21
	push		r24
	push		temp
	in			SREG2, SREG		; Status Register 저장
	
	inc			Timer0cnt
	cpi			Timer0cnt, 244 	; interrupt가 244번 걸리면 1초
	brne		OVF_Done

	clr			Timer0cnt
	cpi			TESTmode, TMODE_PHOTO ; PHOTO DISPLAY에 해당하는 값일 경우
	breq		PHOTO_OVF

	cpi			TESTmode, TMODE_TEMP
	breq		TEMP_OVF

	SETZ		PhoneNum		; PhoneNum의 시작주소
	add			ZL, phonecnt	; phonecnt만큼 주소를 더하기(즉, Z 레지스터의 커서를 이동)
	adc			ZH, r0

	ldi			temp, 16
	cp			phonecnt, temp
	breq		EndPhone

	inc			phonecnt
	SETXY		X, digit4		; digit4의 시작주소		
	ldi			r21, 0x04

Copy_Loop:						; 4개의 Z 값을 옮기기
	lpm			temp, Z+		
	st			X+, temp

	dec			r21
	brne		Copy_Loop
	rjmp		OVF_Done

EndPhone:
	clr			phonecnt
	SETXY		X, digit4		; digit4의 시작주소		
	ldi			r21, 0x04
	rjmp		Copy_Loop

;***************************************************************************
; PHOTO 값 HEXDsiplay 및 FND에 띄우기
;***************************************************************************
PHOTO_OVF:
	call		Read_ADC
	
	SETXY		X, digit4

	mov			temp, ADdataH
	rcall		CDS_HEX
	mov			temp, ADdataL
	rcall		CDS_HEX

	; 1초마다 값 띄우기
	mov			r24, ADdataH
	rcall		HexDisp
	mov			r24, ADdataL
	rcall		HexDisp
	PUTC		CR

	rjmp		OVF_Done

;***************************************************************************
; TEMP_OVF : Temperature 값 FND에 띄우기
;***************************************************************************
TEMP_OVF:
	call		TempRead
	
	SETXY		X, digit4
	rcall		TEMP_DEC

	; 1초마다 값 띄우기
	mov			r24, TWIdataH
	rcall		HexDisp
	mov			r24, TWIdataL
	rcall		HexDisp
	PUTC		CR

OVF_Done:
	out			SREG, SREG2		; Status Register 복구
	pop			temp
	pop			r24
	pop			r21
	pop			ZL
	pop			ZH
	pop			XL
	pop			XH
	
	sei							; Enable
	reti

;***************************************************************************
;* CDS_HEX: HEX 값으로 변환하여 X에 저장
;***************************************************************************
CDS_HEX:
	push		r18

	mov			r18, temp
	andi		temp, 0xf0		; 상위 4bit
	lsr			temp
	lsr			temp
	lsr			temp
	lsr			temp
	st			X+, temp

	mov			temp, r18		; r24 값 복구
	andi		temp, 0x0f		; 하위 4비트 마스킹
	st			X+, temp

	pop			r18
	ret

;***************************************************************************
;* TEMP_DEC : HEX Data의 값을 받아 Dec 온도값으로 변환하여 X에 저장
;***************************************************************************
TEMP_DEC:
	mov			r24, TWIdataH
	sbrc		r24, 7			; 양수일경우 다음 명령 skip
	rjmp		Minus_Degree
	ldi			temp, 17
	st			X+, temp		; DIGIT2
	rcall		DEC2DIGIT
	rjmp		DEC_Done

Minus_Degree:
	ldi			temp, 16
	st			X+, temp
	com			r24
	subi		r24, -1			; 2'th complement
	rcall		DEC2DIGIT

DEC_Done:
	;소수점(하위 8비트)
	mov			r24, TWIdataL
	ldi			temp, 0
	sbrc		r24, 7			; 소수점이 없을 경우 다음 명령 skip
	ldi			temp, 5
	st			X, temp
	ret

DEC2DIGIT:
	mov			temp, r24
	andi		temp, 0x7f
	clr			Quotient

TEMP_DIG2:						; DIGIT2
	cpi			temp, 10
	brlo		TEMP_DIG3
	inc			Quotient
	subi		temp, 10
	rjmp		TEMP_DIG2

TEMP_DIG3:						; DIGIT3
	st			X+, Quotient
	st			X+, temp
	ret

PhoneNum:
	.db 17, 17, 17, 17, 0, 1, 0, 16, 8, 5, 2, 9, 16, 6, 1, 3, 4, 17, 17, 17, 17
	