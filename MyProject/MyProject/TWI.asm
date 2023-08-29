;***************************************************************************
;* TWI Initialization
;***************************************************************************
TWI_Init:
	ldi		temp, 0x03
	out		PORTD, temp		; Pull Up

	; I2C Bitrate를 400K로 설정
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
	ldi		I2Cdata, ATS75_ADDR_W			; Write를 위한 주소
	rcall	TWI_Write
	ldi		I2Cdata, ATS75_TEMP_REG			; internal register pointer
	rcall	TWI_Write

	rcall	TWI_Start
	ldi		I2Cdata, ATS75_ADDR_R			; Read를 위한 주소
	rcall	TWI_Write

	ldi		I2Cack, 1						; 1st Byte Read 후 2nd Byte Read를 위해 ACK 1
	rcall	TWI_Read
	mov		TWIdataH, r24

	ldi		I2Cack, 0						; 2nd Byte Read 후 종료 위해 ACK 0
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
	sbrs	temp, TWINT			; TWINT bit set일 경우 전송완료이므로 다음 명령어 skip
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
;* I2C Write : Transmit Data(Slave의 io address, data 등)를 TWDR에 write
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
;* I2C Read : Slave로부터 받은 데이터(TWDR)를 r24에 담아 반환
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