;***************************************************************************
;* Electronic Piano
;***************************************************************************
PIANO_TEST:
	push	ZH
	push	ZL
	push	YH
	push	YL
	push	CodeCount
	push	ToneSong
	push	r24

	cli
	rcall	init_Timer2
	sei

	ldi		temp, 0x10
	out		DDRB, temp
	clr		BUZMode

PlayPiano:
	cli
	SETXY	Y, buffer
	rcall	GetString
	PUTC	CR

	; CTRL-C 입력 시 종료
	SETXY	Y, buffer
	ld		temp, Y
	cpi		temp, CTRL_C
	breq	DONE_PIANO

	clr		CodeCount
	SETZ	CodeList

CompCode:
	call	StrCmp 
	tst		r24
	breq	PlayCode
	inc		CodeCount

	; 잘못된 입력 시 Code 다시 칠 수 있도록 설계
	ldi		temp, 36
	cp		CodeCount, temp
	breq	PlayPiano		
	
	ADDI16	Z, 6
	rjmp	CompCode

PlayCode:
	sei
	SETZ	PianoCode
	add		ZL, CodeCount
	adc		ZH, r0

	lpm		temp, Z
	mov		ToneSong, temp
	DELAYMS	500
	rjmp	PlayPiano 


DONE_PIANO:
	cli

	out		PORTB, r0		; PORTB를 off시키기
	out		TIMSK, r0		; 더 이상 인터럽트 발생X

	pop		r24
	pop		ToneSong
	pop		CodeCount
	pop		YL
	pop		YH
	pop		ZL
	pop		ZH
	ret

