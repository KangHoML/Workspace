;***************************************************************************
;* UART Initialization
;***************************************************************************
Uart_Init:
	; BAUDRATE ����
	ldi		temp, HIGH(UBRR0)
	sts		UBRR0H, temp		; External I/O�̱� ������ sts ��ɾ�
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
	cpi		r24, CR				; Enter Key �Է����� Ȯ��
	brne	PutData

InsertLF:
	push	r24					; CR ����
	ldi		r24, LF
	rcall	PutChar
	pop		r24					; CR ����
	
PutData:
	sbis	UCSR0A, UDRE0		; UCSR0A�� bit 5(UDR�� Empty�� ��� 1)
	rjmp	PutData				
	out		UDR0, r24			; Empty�� ��� UDR0�� r24 �� ����
	ret

;***************************************************************************
;* GetChar : receive a character from RS232C Port
;***************************************************************************
GetChar:
	sbis	UCSR0A, RXC0		; UCSR0A�� bit 7(Recieve Complete�� ��� 1)
	rjmp	GetChar				
	in		r24, UDR0			; Complete�� ��� UDR0�� r24 �� ����
	ret

;***************************************************************************
;* PutString : Program Memory�� ���� load�� terminal�� ���
;***************************************************************************
PutString:
	lpm		r24, Z+				
	cpi		r24, EOS			; Program Memory���� load�� �� ���� EOS���� Ȯ��(������ ������ Ȯ��)
	breq	EndPutPM
	rcall	PutChar				; EOS�� �ƴ϶�� ���
	rjmp	PutString			; EOS�� ������ �ݺ�

EndPutPM:
	ret

;***************************************************************************
;* GetString : PuTTyâ�� ���� �Է��� �޾� buffer�� ����
;***************************************************************************
GetString:
	push	temp

Loop:
	rcall	GetChar				; �ѱ��ھ� �о����
	cpi		r24, CR				; ���͸� �Է��ߴ��� Ȯ��
	breq	EndGet
	
	cpi		r24, BS				; BackSpace�Է� Ȯ��
	breq	Back

	rcall	PutChar				; ���Ͱ� �ƴϸ� Echoing
	st		Y+, r24				; Y�� ����
	rjmp	Loop				; EOS�� ������ �ݺ�

Back:
	sbiw	Y, 1				; Y ����Ű�� �ּ� �� ĭ ������
	rcall	PutChar
	rjmp	Loop

EndGet:
	ldi		temp, EOS
	st		Y, temp				; ������ �������� EOS �Է�

	pop		temp
	ret

;***************************************************************************
;* PutStringD : DataMemory�� ���� load�� terminal�� ���
;***************************************************************************
PutStringD:
	ld		r24, Y+	
	cpi		r24, EOS			; Data Memory���� load�� �� ���� EOS���� Ȯ��(������ ������ Ȯ��)
	breq	EndPutDM
	rcall	PutChar				; EOS�� �ƴ϶�� ���
	rjmp	PutStringD			; EOS�� ������ �ݺ�

EndPutDM:
	ret

;***************************************************************************
;* HEX Display : Key �Է¿� ���Ͽ� ASCII CODE���� �ش��ϴ� ���ڷ� ���
;***************************************************************************
HexDisp:
	push	r18

	mov		r18, r24			; r24 �� ����
	andi	r24, 0xf0			; ���� 4��Ʈ ����ŷ
	lsr		r24
	lsr		r24
	lsr		r24
	lsr		r24
	rcall	Int2Ascii
	rcall	PutChar

	mov		r24, r18			; r24 �� ����
	andi	r24, 0x0f			; ���� 4��Ʈ ����ŷ
	rcall	Int2Ascii
	rcall	PutChar

	pop		r18
	ret

;***************************************************************************
;* Int2Ascii : ������ ASCII ������ ��ȯ
;***************************************************************************
Int2Ascii:
	cpi		r24, 10				; 10���� ū�� ��
	brsh	ASCII10				; 10���� ũ�ų� ������ branch
	subi	r24, -'0'			; a�� �ƽ�Ű�ڵ尪-10 ���ϱ�(a�� 10�̱� ����)
	ret

; 10(a)���� ū ���� ���� ASCII ó�� 
ASCII10:
	subi	r24, -('A' - 10)
	ret
