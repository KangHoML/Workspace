;***************************************************************************
;* SegN Display with stop by CTRL-C
;***************************************************************************
SEGN_TEST:
	push	temp

	rcall	UARTInt_On		; �ش� �Լ�(Service Routine) �������� RX Interrupt ����
	cli						; Disable Interrupt
	rcall	ExInt_init
	rcall	Timer1_init

	; 7SEG�� ���� PortC�� DDR ����
	ser		temp
	out		DDRC, temp

	; 4���� 7SEG�� �����ϱ� ���� PortG�� DDR ����
	ldi		temp, $0F		; ���� 4bit�� ���
	sts		DDRG, temp		; Extended I/O Port

	ldi		TESTmode, TMODE_SEGN

	; �ʱ⼳��
	mov		GoStop, r2			; Go
	SETDigit4	0,0,0,0
	sei

Check_SEGN:
	tst		TESTmode			; 0(CTRL-C ���� �Էµ�)���� üũ
	breq	DONE_SEGN			; 0�� ��� SEGN Off
	ldi		FND_En, 0x08		; Enable�� 0000 1000���� ����
	SETXY	X, digit4			; X�� �ٽ� digit4�� �����ּҷ� ����

SEGN_Loop:
	sts		PORTG, FND_En	; PORTG�� FND_En�� ����(�� ��° 7seg�� ų ������ ����) 
	ld		temp, X+		; Offset �� ��������
	
	SETZ	SegData			; PM�� SegData�� �����ּҸ� Z �������ͷ� ����
	add		ZL, temp		; Offset��ŭ �ּҸ� ���ϱ�(��, Z ���������� Ŀ���� �̵�)
	add		ZH, r0

	lpm		FND_Data, Z		; ���� Z �������Ͱ� ����Ű�� �ִ� �ּ� ���� ���� Load
	out		PORTC, FND_Data	; Port C�� ���� ���

	DELAYMS 1
	
	// 4���� 7SEG�� ���� �ݺ��� ��ġ�� �ٽ� ó�� 7SEG�� ���ư��� ���� shift
	lsr		FND_En			; �ϳ� �ڷ� �ű�� ���� logistic shift right
	breq	Check_SEGN		; 0000�� �Ǹ� �ٽ� 1000���� SetLoop���� ���ư���
	rjmp	SEGN_Loop
	

DONE_SEGN:
	cli
	ldi		temp, 0x00

	; External Interrupt off
	out		EIMSK, temp

	; PORTC off
	out		PORTC, temp

	; PORTG off
	sts		PORTG, temp

	; Timer1 off
	out		TIMSK, temp
	
	rcall	UARTint_off
	pop		temp
	ret

;***************************************************************************
; Initialization
; clock source : system clock
; clock value : 16MHz / 8 = 2Mhz;
; overflow interrupt freq : 100Hz
;***************************************************************************

ExInt_init:
	cli

	ldi		temp, 0x00
	sts		EICRA, temp		; �ּҷ� ���� in/out ��ɾ� �Ұ����ϹǷ� sts ��ɾ� ���

	ldi		temp, 0x0A
	out		EICRB, temp		; Switch 4, 5 falling edge

	ldi		temp, 0x30
	out		EIMSK, temp		; External Interrupt�� Mask Register ����

	sei
	ret

Timer1_init:
	ldi		temp, 0x02		; Clock Source = 16MHz / 8
	out		TCCR1B, temp

	; 45536~65536 ��, 20000���� ���� 1/100sec ����
	ldi		temp, HIGH(45536)		
	out		TCNT1H, temp
	ldi		temp, LOW(45536)
	out		TCNT1L, temp

	ldi		temp, 0x04		; Timer1 Overflow�� Interrupt�� Enable
	out		TIMSK, temp
	
	ret

Timer1_OVF:
	cli						; Disable Interrupt
	push	XH
	push	XL
	push	temp
	in		SREG2, SREG		; Status Register ����
	
	; �� ���ͷ�Ʈ�� 0.01���̹Ƿ� Time0cnt�� �ʿ�X -> ��, TCNT 16 bit �������͸� �ٽ� 45536���� �ʱ�ȭ �ʿ�
	; 45536~65536 ��, 20000���� ���� 1/100sec ����
	ldi		temp, HIGH(45536)		
	out		TCNT1H, temp
	ldi		temp, LOW(45536)
	out		TCNT1L, temp

UpdateTime:
	cp		GoStop, r0		; GoStop�� 0�̸� ������ digit�� ���� �ø��� ����(Stop)
	breq	UpdateDone
	
	SETXY	X, digit4		; digit4�� �����ּҸ� X �������Ϳ� ����
	
	ldi		temp, 3			; X�������Ͱ� ����Ű�� Ŀ���� 3��ŭ �Ű��ֱ� ���ؼ�
	add		XL, temp
	add		XH, r0

	ld		temp, X			; X�� ����Ű�� �ּ� ���� ��(���� digit4�� 4��° ���� ����Ŵ)
	inc		temp
	cpi		temp, 10		; ������ �ڸ��� 10�� �Ǵ��� ��
	breq	Update_2
	st		X, temp			; X�� ����Ű�� �ּҿ� temp ����
	
UpdateDone:
	out		SREG, SREG2		; Status Register ����
	pop		temp
	pop		XL
	pop		XH
	
	sei						; Enable
	reti

Update_2:
	clr		temp			; temp(digit4�� 4��° �ڸ� �ʱ�ȭ)
	st		X, temp

	ld		temp, -X		; digit4�� 3��° �ڸ� �� ��������
	inc		temp
	cpi		temp, 10		; 3��° �ڸ��� 10�� �Ǵ��� ��
	breq	Update_1
	st		X, temp			
	rjmp	UpdateDone

Update_1:
	clr		temp			; temp(digit4�� 3��° �ڸ� �ʱ�ȭ)
	st		X, temp

	ld		temp, -X		; digit4�� 2��° �ڸ� �� ��������
	inc		temp
	cpi		temp, 10		; 2��° �ڸ��� 10�� �Ǵ��� ��
	breq	Update_0
	st		X, temp			
	rjmp	UpdateDone

Update_0:
	clr		temp			; temp(digit4�� 3��° �ڸ� �ʱ�ȭ)
	st		X, temp

	ld		temp, -X		; digit4�� 1��° �ڸ� �� ��������
	inc		temp
	cpi		temp, 6			; 1��° �ڸ��� 6�� �Ǵ��� ��
	breq	Update_0
	st		X, temp			
	rjmp	UpdateDone

Ext_Int4:
	
	cli							; Disable Interrupt
	push		XH
	push		XL
	push		temp
	push		r24
	push		r25
	in			SREG2, SREG		; Status Register ����
	
	cpi			TESTmode, 0x08
	breq		Ex4_Proj
	
	SETDigit4	0,0,0,0			; ����ġ 4�� ������ 00:00���� �����
	mov			GoStop, r0		; GoStop�� 0���� �����(stop)
	DELAYMS		10
	rjmp		Ex4_Done

Ex4_Proj:
	// ???
		
Ex4_Done:

	out			SREG, SREG2		; Status Register ����
	pop			r25
	pop			r24
	pop			temp
	pop			XL
	pop			XH
	sei							; Enable
	ret

Ext_Int5:

	cli							; Disable Interrupt
	push		XH
	push		XL
	push		temp
	push		r24
	push		r25
	in			SREG2, SREG		; Status Register ����

	cpi			TESTmode, 0x08
	breq		Ex5_Proj

	com			GoStop	 		; GoStop�� ����
	DELAYMS		10
	rjmp		Ex5_Done

Ex5_Proj:
	// ???

Ex5_Done:
	out			SREG, SREG2		; Status Register ����
	pop			r25
	pop			r24
	pop			temp
	pop			XL
	pop			XH
	sei							; Enable
	ret