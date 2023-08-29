;***************************************************************************
;* LED Display with stop by CTRL-C
;***************************************************************************
LED_TEST:
	rcall	UARTInt_On			; 해당 함수(Service Routine) 내에서만 RX Interrupt 실행
	out		DDRA, r2
	ldi		TESTmode, TMODE_LED
	sei

Check_LED:
	tst		TESTmode			; 0(CTRL-C 값이 입력됨)인지 체크
	breq	DONE_LED			; 0일 경우 LED Off

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
