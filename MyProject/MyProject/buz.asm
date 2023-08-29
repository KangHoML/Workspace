;***************************************************************************
;* BUZ Display with stop by CTRL-C
;***************************************************************************
BUZ_TEST:
	push	temp
	rcall	UARTInt_On		; �ش� �Լ�(Service Routine) �������� RX Interrupt ����

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
	tst		TESTmode			; 0(CTRL-C ���� �Էµ�)���� üũ
	breq	DONE_BUZ			; 0�� ��� BUZ Off

Play:
	lpm		temp, Z+		; Program Memory�� �ִ� ���̸��� ��������
	
	cp		temp, r0		; temp�� 0���� ��
	breq	Set_BUZ			; 0�̸� ��

	mov		ToneSong, temp
	DELAYMS 500				; 60BPM

	rjmp	Check_BUZ

DONE_BUZ:
	cli
	out		PORTB, r0		; PORTB�� off��Ű��
	out		TIMSK, r0		; �� �̻� ���ͷ�Ʈ �߻�X

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

	tst		BUZMode			; BUZMode�� 0�� ���
	brne	BUZZER_ON		; BUZMode�� 1�� ���

BUZZER_OFF:
	mov		BUZMode, r1		; ��带 On(0xff)���� ��ȯ
	ldi		temp, BUZ_ON	
	out		PORTB, temp		; Port�� ���
	rjmp	ChangeMode_Done

BUZZER_ON:
	clr		BUZMode			; ��带 Off(0x00)�� ��ȯ
	out		PORTB, r0		; Port�� ���

ChangeMode_Done:
	mov		temp, ToneSong	; �ش� ���� �ش��ϴ� ���ļ��� ���� TCNT ���� ����
	out		TCNT2, temp;

	pop		temp
	out		SREG, SREG2
	sei
	reti

SONG:
	.db DO, RE, MI, FA, SOL, RA, SI, DDO, EndSong, EndSong
