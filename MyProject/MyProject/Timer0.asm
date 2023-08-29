;***************************************************************************
; Timer/Counter 0 initialization
; clock source : system clock
; clock value : 16MHz / 256 = 62.5Khz;
; overflow interrupt freq : 62500 / 256 = 244.14Hz
; phone.asm and photo.asm
;***************************************************************************
Timer0_init:
	ldi			temp, 0x06		; Clock Source = 16MHz / 256
	out			TCCR0, temp

	ldi			temp, 0x00		
	out			TCNT0, temp		; 0 ~ 255���� �� ���(��, FF -> 00���� ���� �� Interrupt �߻�)

	ldi			temp, 1			; Timer0���� Interrupt ��ȣ�� Enable��
	out			TIMSK, temp
	
	ret

Timer0_OVF:
	cli
	push		XH
	push		XL
	push		ZH
	push		ZL
	push		r21
	push		r24
	push		temp
	in			SREG2, SREG		; Status Register ����
	
	inc			Timer0cnt
	cpi			Timer0cnt, 244 	; interrupt�� 244�� �ɸ��� 1��
	brne		OVF_Done

	clr			Timer0cnt
	cpi			TESTmode, TMODE_PHOTO ; PHOTO DISPLAY�� �ش��ϴ� ���� ���
	breq		PHOTO_OVF

	cpi			TESTmode, TMODE_TEMP
	breq		TEMP_OVF

	SETZ		PhoneNum		; PhoneNum�� �����ּ�
	add			ZL, phonecnt	; phonecnt��ŭ �ּҸ� ���ϱ�(��, Z ���������� Ŀ���� �̵�)
	adc			ZH, r0

	ldi			temp, 16
	cp			phonecnt, temp
	breq		EndPhone

	inc			phonecnt
	SETXY		X, digit4		; digit4�� �����ּ�		
	ldi			r21, 0x04

Copy_Loop:						; 4���� Z ���� �ű��
	lpm			temp, Z+		
	st			X+, temp

	dec			r21
	brne		Copy_Loop
	rjmp		OVF_Done

EndPhone:
	clr			phonecnt
	SETXY		X, digit4		; digit4�� �����ּ�		
	ldi			r21, 0x04
	rjmp		Copy_Loop

;***************************************************************************
; PHOTO �� HEXDsiplay �� FND�� ����
;***************************************************************************
PHOTO_OVF:
	call		Read_ADC
	
	SETXY		X, digit4

	mov			temp, ADdataH
	rcall		CDS_HEX
	mov			temp, ADdataL
	rcall		CDS_HEX

	; 1�ʸ��� �� ����
	mov			r24, ADdataH
	rcall		HexDisp
	mov			r24, ADdataL
	rcall		HexDisp
	PUTC		CR

	rjmp		OVF_Done

;***************************************************************************
; TEMP_OVF : Temperature �� FND�� ����
;***************************************************************************
TEMP_OVF:
	call		TempRead
	
	SETXY		X, digit4
	rcall		TEMP_DEC

	; 1�ʸ��� �� ����
	mov			r24, TWIdataH
	rcall		HexDisp
	mov			r24, TWIdataL
	rcall		HexDisp
	PUTC		CR

OVF_Done:
	out			SREG, SREG2		; Status Register ����
	pop			temp
	pop			r24
	pop			r21
	pop			ZL
	pop			ZH
	pop			XL
	pop			XH
	
	sei							; Enable
	reti

;***************************************************************************
;* CDS_HEX: HEX ������ ��ȯ�Ͽ� X�� ����
;***************************************************************************
CDS_HEX:
	push		r18

	mov			r18, temp
	andi		temp, 0xf0		; ���� 4bit
	lsr			temp
	lsr			temp
	lsr			temp
	lsr			temp
	st			X+, temp

	mov			temp, r18		; r24 �� ����
	andi		temp, 0x0f		; ���� 4��Ʈ ����ŷ
	st			X+, temp

	pop			r18
	ret

;***************************************************************************
;* TEMP_DEC : HEX Data�� ���� �޾� Dec �µ������� ��ȯ�Ͽ� X�� ����
;***************************************************************************
TEMP_DEC:
	mov			r24, TWIdataH
	sbrc		r24, 7			; ����ϰ�� ���� ��� skip
	rjmp		Minus_Degree
	ldi			temp, 17
	st			X+, temp		; DIGIT2
	rcall		DEC2DIGIT
	rjmp		DEC_Done

Minus_Degree:
	ldi			temp, 16
	st			X+, temp
	com			r24
	subi		r24, -1			; 2'th complement
	rcall		DEC2DIGIT

DEC_Done:
	;�Ҽ���(���� 8��Ʈ)
	mov			r24, TWIdataL
	ldi			temp, 0
	sbrc		r24, 7			; �Ҽ����� ���� ��� ���� ��� skip
	ldi			temp, 5
	st			X, temp
	ret

DEC2DIGIT:
	mov			temp, r24
	andi		temp, 0x7f
	clr			Quotient

TEMP_DIG2:						; DIGIT2
	cpi			temp, 10
	brlo		TEMP_DIG3
	inc			Quotient
	subi		temp, 10
	rjmp		TEMP_DIG2

TEMP_DIG3:						; DIGIT3
	st			X+, Quotient
	st			X+, temp
	ret

PhoneNum:
	.db 17, 17, 17, 17, 0, 1, 0, 16, 8, 5, 2, 9, 16, 6, 1, 3, 4, 17, 17, 17, 17
	