;***************************************************************************
;* UART Initialization
;***************************************************************************
Uart_Init:
	; BAUDRATE 설정
	ldi		temp, HIGH(UBRR0)
	sts		UBRR0H, temp		; External I/O이기 때문에 sts 명령어
	ldi		temp, LOW(UBRR0)
	out		UBRR0L, temp
	
	; TX, RX Enable
	ldi		temp, 0x18
	out		UCSR0B, temp

	; Default Mode
	ldi		temp, 0x06
	sts		UCSR0C, temp

	ret

;***************************************************************************
;* PutChar : send a character to RS232C Port
;***************************************************************************
PutChar:
	cpi		r24, CR				; Enter Key 입력인지 확인
	brne	PutData

InsertLF:
	push	r24					; CR 저장
	ldi		r24, LF
	rcall	PutChar
	pop		r24					; CR 복구
	
PutData:
	sbis	UCSR0A, UDRE0		; UCSR0A의 bit 5(UDR이 Empty인 경우 1)
	rjmp	PutData				
	out		UDR0, r24			; Empty인 경우 UDR0에 r24 값 저장
	ret

;***************************************************************************
;* GetChar : receive a character from RS232C Port
;***************************************************************************
GetChar:
	sbis	UCSR0A, RXC0		; UCSR0A의 bit 7(Recieve Complete인 경우 1)
	rjmp	GetChar				
	in		r24, UDR0			; Complete인 경우 UDR0에 r24 값 저장
	ret

;***************************************************************************
;* PutString : Program Memory의 값을 load해 terminal에 출력
;***************************************************************************
PutString:
	lpm		r24, Z+				
	cpi		r24, EOS			; Program Memory에서 load해 온 값이 EOS인지 확인(문장의 끝인지 확인)
	breq	EndPutPM
	rcall	PutChar				; EOS가 아니라면 출력
	rjmp	PutString			; EOS일 때까지 반복

EndPutPM:
	ret

;***************************************************************************
;* GetString : PuTTy창을 통한 입력을 받아 buffer에 저장
;***************************************************************************
GetString:
	push	temp

Loop:
	rcall	GetChar				; 한글자씩 읽어오기
	cpi		r24, CR				; 엔터를 입력했는지 확인
	breq	EndGet
	
	cpi		r24, BS				; BackSpace입력 확인
	breq	Back

	rcall	PutChar				; 엔터가 아니면 Echoing
	st		Y+, r24				; Y에 저장
	rjmp	Loop				; EOS일 때까지 반복

Back:
	sbiw	Y, 1				; Y 가리키는 주소 한 칸 앞으로
	rcall	PutChar
	rjmp	Loop

EndGet:
	ldi		temp, EOS
	st		Y, temp				; 문장의 마지막에 EOS 입력

	pop		temp
	ret

;***************************************************************************
;* PutStringD : DataMemory의 값을 load해 terminal에 출력
;***************************************************************************
PutStringD:
	ld		r24, Y+	
	cpi		r24, EOS			; Data Memory에서 load해 온 값이 EOS인지 확인(문장의 끝인지 확인)
	breq	EndPutDM
	rcall	PutChar				; EOS가 아니라면 출력
	rjmp	PutStringD			; EOS일 때까지 반복

EndPutDM:
	ret

;***************************************************************************
;* HEX Display : Key 입력에 대하여 ASCII CODE값에 해당하는 문자로 출력
;***************************************************************************
HexDisp:
	push	r18

	mov		r18, r24			; r24 값 저장
	andi	r24, 0xf0			; 상위 4비트 마스킹
	lsr		r24
	lsr		r24
	lsr		r24
	lsr		r24
	rcall	Int2Ascii
	rcall	PutChar

	mov		r24, r18			; r24 값 복구
	andi	r24, 0x0f			; 하위 4비트 마스킹
	rcall	Int2Ascii
	rcall	PutChar

	pop		r18
	ret

;***************************************************************************
;* Int2Ascii : 정수를 ASCII 값으로 변환
;***************************************************************************
Int2Ascii:
	cpi		r24, 10				; 10보다 큰지 비교
	brsh	ASCII10				; 10보다 크거나 같으면 branch
	subi	r24, -'0'			; a의 아스키코드값-10 더하기(a가 10이기 때문)
	ret

; 10(a)보다 큰 수에 대한 ASCII 처리 
ASCII10:
	subi	r24, -('A' - 10)
	ret
