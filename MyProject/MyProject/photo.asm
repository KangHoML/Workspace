;***************************************************************************
;* Photo Display with stop by CTRL-C
;***************************************************************************
PHOTO_TEST:
	push	ZH
	push	ZL
	push	XH
	push	XL
	push	temp

	rcall	UARTInt_On		; �ش� �Լ�(Service Routine) �������� RX Interrupt ����
	rcall	ADC_Init		; AD Converter �����Լ� �ʱ�ȭ

	cli						; Disable Interrupt
	rcall	Timer0_init
	sei						; Enable Interrupt

	; 7SEG�� ���� PortC�� DDR ����
	ser		temp
	out		DDRC, temp

	; 4���� 7SEG�� �����ϱ� ���� PortG�� DDR ����
	ldi		temp, $0F		; ���� 4bit�� ���
	sts		DDRG, temp		; Extended I/O Port

	ldi		TESTmode, TMODE_PHOTO

	SetDigit4	17, 17, 17, 17

Check_PHOTO:
	tst		TESTmode
	breq	DONE_PHOTO
	ldi		FND_En, 0x08		; Enable�� 0000 1000���� ����
	SETXY	X, digit4			; X�� �ٽ� digit4�� �����ּҷ� ����

PHOTO_Loop:
	sts		PORTG, FND_En	; PORTG�� FND_En�� ����(�� ��° 7seg�� ų ������ ����) 
	ld		temp, X+		; Offset �� ��������

	SETZ	SegData			; PM�� SegData�� �����ּҸ� Z �������ͷ� ����
	add		ZL, temp		; Offset��ŭ �ּҸ� ���ϱ�(��, Z ���������� Ŀ���� �̵�)
	adc		ZH, r0
	
	lpm		FND_Data, Z		; ���� Z �������Ͱ� ����Ű�� �ִ� �ּ� ���� ���� Load
	out		PORTC, FND_Data	; Port C�� ���� ���

	DELAYMS 1
	
	// 4���� 7SEG�� ���� �ݺ��� ��ġ�� �ٽ� ó�� 7SEG�� ���ư��� ���� shift
	lsr		FND_En			; �ϳ� �ڷ� �ű�� ���� logistic shift right
	breq	Check_PHOTO		; 0000�� �Ǹ� �ٽ� 1000���� SetLoop���� ���ư���
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