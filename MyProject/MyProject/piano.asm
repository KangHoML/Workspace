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

	; CTRL-C �Է� �� ����
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

	; �߸��� �Է� �� Code �ٽ� ĥ �� �ֵ��� ����
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

	out		PORTB, r0		; PORTB�� off��Ű��
	out		TIMSK, r0		; �� �̻� ���ͷ�Ʈ �߻�X

	pop		r24
	pop		ToneSong
	pop		CodeCount
	pop		YL
	pop		YH
	pop		ZL
	pop		ZH
	ret

