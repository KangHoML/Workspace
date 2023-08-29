;***************************************************************************
;* LED Display with stop by CTRL-C
;***************************************************************************
LED_TEST:
	rcall	UARTInt_On			; �ش� �Լ�(Service Routine) �������� RX Interrupt ����
	out		DDRA, r2
	ldi		TESTmode, TMODE_LED
	sei

Check_LED:
	tst		TESTmode			; 0(CTRL-C ���� �Էµ�)���� üũ
	breq	DONE_LED			; 0�� ��� LED Off

	ldi		temp, 0x80
	mov		LEDData, temp

LED_Loop:						; LED Control
	out		PORTA, LEDData
	DELAYMS	100

	lsr		LEDData
	brne	LED_Loop

	rjmp	Check_LED

Done_LED:
	cli
	clr		LEDData
	out		PORTA, LEDData
	rcall	UARTint_off
	
	ret
