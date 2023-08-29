;***************************************************************************
;* Play Audio
;***************************************************************************
AUDIO_TEST:
	push	ZH
	push	ZL
	push	YH
	push	YL
	push	CodeCount
	push	ToneSong
	push	r24
	push	LocationY

	cli
	rcall	init_Timer2
	sei

	ldi		temp, 0x10
	out		DDRB, temp
	clr		BUZMode

AUDIO_INPUT:
	cli
	out		PORTB, r0

	SETXY	Y, StoreSong
	rcall	GetString
	PUTC	CR

	SETXY	Y, StoreSong
	ld		temp, Y
	cpi		temp, CTRL_C
	breq	DONE_AUDIO

SPACEBAR:
	ld		temp, Y+
	
	cpi		temp, SP
	breq	SP2EOS
	
	cpi		temp, EOS
	breq	Audio_Start
	rjmp	SPACEBAR

SP2EOS:
	ldi		temp, EOS
	st		-Y, temp

	ldi		temp, 1
	add		YL, temp
	adc		YH, r0

	rjmp	SPACEBAR
	
Audio_Start:
	ldi		temp, 0xff		; SPACEBAR가 아닌 진짜 마지막 EOS를 구분
	st		Y, temp
	SETXY	Y, StoreSong
	
Comp_Start:
	ld		temp, Y
	cpi		temp, 0xff
	breq	AUDIO_INPUT
	clr		CodeCount
	SETZ	CodeList

Comp_Audio:
	clr		LocationY
	call	StrCmp

	tst		r24
	breq	Play_Audio
	inc		CodeCount

	ADDI16	Z, 6
	rjmp	Comp_Audio

Play_Audio:
	sei

	SETZ	PianoCode
	add		ZL, CodeCount
	adc		ZH, r0

	lpm		temp, Z
	mov		ToneSong, temp
	DELAYMS	500

	add		YL, LocationY
	adc		YH, r0

	rjmp	Comp_Start
	
DONE_AUDIO:
	cli

	clr		TESTmode

	out		PORTB, r0		; PORTB를 off시키기
	out		TIMSK, r0		; 더 이상 인터럽트 발생X
	
	pop		LocationY
	pop		r24
	pop		ToneSong
	pop		CodeCount
	pop		YL
	pop		YH
	pop		ZL
	pop		ZH
	ret