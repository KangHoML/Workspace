;***************************************************************************
;* TWI Initialization
;***************************************************************************
TWI_Init:
	ldi		temp, 0x03
	out		PORTD, temp		; Pull Up

	; I2C Bitrate�� 400K�� ����
	ldi		temp, 12
	sts		TWBR, temp
	ldi		temp, (0<<TWPS1)|(0<<TWPS0);
	sts		TWSR, temp

	ret

;***************************************************************************
;* Temperature Sensor Read
;***************************************************************************
TempRead:
	push	r24
	
	rcall	TWI_Start
	ldi		I2Cdata, ATS75_ADDR_W			; Write�� ���� �ּ�
	rcall	TWI_Write
	ldi		I2Cdata, ATS75_TEMP_REG			; internal register pointer
	rcall	TWI_Write

	rcall	TWI_Start
	ldi		I2Cdata, ATS75_ADDR_R			; Read�� ���� �ּ�
	rcall	TWI_Write

	ldi		I2Cack, 1						; 1st Byte Read �� 2nd Byte Read�� ���� ACK 1
	rcall	TWI_Read
	mov		TWIdataH, r24

	ldi		I2Cack, 0						; 2nd Byte Read �� ���� ���� ACK 0
	rcall	TWI_Read
	mov		TWIdataL, r24

	rcall	TWI_Stop

	pop		r24
	ret

;***************************************************************************
;* Set TWI Communication Start
;***************************************************************************
TWI_Start:
	ldi		temp, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
	sts		TWCR, temp

TWI_Wait1:
	lds		temp, TWCR
	sbrs	temp, TWINT			; TWINT bit set�� ��� ���ۿϷ��̹Ƿ� ���� ��ɾ� skip
	rjmp	TWI_Wait1
	ret

;***************************************************************************
;* Set TWI Communication Stop
;***************************************************************************
TWI_Stop:
	ldi		temp, (1<<TWINT)|(1<<TWSTO)|(1<<TWEN)
	sts		TWCR, temp

	ldi		temp, 100			; time delay
TWI_Wait2:
	dec		temp
	brne	TWI_Wait2
	ret

;***************************************************************************
;* I2C Write : Transmit Data(Slave�� io address, data ��)�� TWDR�� write
;***************************************************************************
TWI_Write:
	sts		TWDR, I2Cdata
	ldi		temp, (1<<TWINT)|(1<<TWEN)
	sts		TWCR, temp

TWI_Wait3:
	lds		temp, TWCR
	sbrs	temp, TWINT
	rjmp	TWI_Wait3
	ret

;***************************************************************************
;* I2C Read : Slave�κ��� ���� ������(TWDR)�� r24�� ��� ��ȯ
;***************************************************************************
TWI_Read:
	ldi		temp, (1<<TWINT) | (1<<TWEN) | (0<<TWEA)
	cpi		I2Cack, 0
	breq	SecondRead
	ldi		temp, (1<<TWINT) | (1<<TWEN) | (1<<TWEA)

SecondRead:
	sts		TWCR, temp

TWI_Wait4:
	lds		temp,TWCR
	sbrs	temp, TWINT
	rjmp	TWI_Wait4

	lds		r24, TWDR
	ret