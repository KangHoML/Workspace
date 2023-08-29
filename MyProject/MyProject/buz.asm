;***************************************************************************
;* BUZ Display with stop by CTRL-C
;***************************************************************************
BUZ_TEST:
	push	temp
	rcall	UARTInt_On		; 해당 함수(Service Routine) 내에서만 RX Interrupt 실행

	cli
	rcall	init_Timer2
	sei

	ldi		temp, 0x10
	out		DDRB, temp
	clr		BUZMode

	ldi		TESTmode, TMODE_BUZ

Set_BUZ:
	SETZ	Song

Check_BUZ:
	tst		TESTmode			; 0(CTRL-C 값이 입력됨)인지 체크
	breq	DONE_BUZ			; 0일 경우 BUZ Off

Play:
	lpm		temp, Z+		; Program Memory에 있는 계이름을 가져오기
	
	cp		temp, r0		; temp가 0인지 비교
	breq	Set_BUZ			; 0이면 끝

	mov		ToneSong, temp
	DELAYMS 500				; 60BPM

	rjmp	Check_BUZ

DONE_BUZ:
	cli
	out		PORTB, r0		; PORTB를 off시키기
	out		TIMSK, r0		; 더 이상 인터럽트 발생X

	rcall	UARTint_off

	pop		temp
	ret


;***************************************************************************
; Timer/Counter 2 initialization
; clock source : system clock
; clock value : 16MHz / 32 = 500Khz;
;***************************************************************************

Init_Timer2:
	ldi		temp, 0x03		; 500KHz
	out		TCCR2, temp

	ldi		temp, 1<<6		; Timer2 Overflow interrupt -> enable
	out		TIMSK, temp

	ret

Timer2_OVF:
	cli
	in		SREG2, SREG
	push	temp

	tst		BUZMode			; BUZMode가 0일 경우
	brne	BUZZER_ON		; BUZMode가 1일 경우

BUZZER_OFF:
	mov		BUZMode, r1		; 모드를 On(0xff)으로 전환
	ldi		temp, BUZ_ON	
	out		PORTB, temp		; Port에 출력
	rjmp	ChangeMode_Done

BUZZER_ON:
	clr		BUZMode			; 모드를 Off(0x00)로 전환
	out		PORTB, r0		; Port에 출력

ChangeMode_Done:
	mov		temp, ToneSong	; 해당 음에 해당하는 주파수를 위한 TCNT 값을 저장
	out		TCNT2, temp;

	pop		temp
	out		SREG, SREG2
	sei
	reti

SONG:
	.db DO, RE, MI, FA, SOL, RA, SI, DDO, EndSong, EndSong
