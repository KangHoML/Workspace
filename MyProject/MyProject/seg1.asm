;***************************************************************************
;* Seg1 Display with stop by CTRL-C
;***************************************************************************
SEG1_TEST:
	push	r0
	push	temp
	push	FND_En
	push	FNDcnt
	rcall	UARTInt_On			; �ش� �Լ�(Service Routine) �������� RX Interrupt ����

	; �����Ʈ C�� DDR ����
	ldi		temp, $FF
	out		DDRC, temp		; 7Seg�� 8bit�� ��� ���

	; ��Ʈ G�� DDR ����(4���� 7Seg�̹Ƿ� ���� 4bit�� �ʿ�)
	ldi		temp, $0F
	sts		DDRG, temp		; ���� 4���� bit�� ����ϹǷ� 0F���� ����

	ldi		TESTmode, TMODE_SEG1
	sei

Set_Loop:
	ldi		FND_En, $08		; ù��° 7seg�� ���� FND_En�� 0000 1000 ����

Check_SEG1:
	tst		TESTmode		; 0(CTRL-C ���� �Էµ�)���� üũ
	breq	DONE_SEG1		; 0�� ��� SEG1 Off


SEG1_Loop:
	sts		PORTG, FND_En	; PORTG�� FND_En�� ����(�� ��° 7seg�� ų ������ ����) 
	ldi		FNDcnt, 10		; 10�� �ݺ�
	SETZ	SegData			; Z �������Ϳ� Program Memory�� SegData�� �����ּ�

Loops:
	lpm		r0, Z+			; �� �������� Z ���������� Ŀ�� �ϳ� ����
	out		PORTC, r0		; ������ ���� C ��Ʈ�� ���� ���

	DELAYMS 100				; 0.1�� Delay

	dec		FNDcnt
	brne	Loops

	lsr		FND_En			; �ϳ� �ڷ� �ű�� ���� logistic shift right
	brne	Check_Seg1		; 0000�ƴ� �� SEG1_Loop

	rjmp	Set_Loop		; 0000�� ��� Set_Loop�� �̵�
	
DONE_SEG1:
	cli
	
	; PORTC off
	ldi		temp, 0x00
	out		PORTC, temp

	; PORTG off
	clr		FND_En
	sts		PORTG, FND_En

	rcall	UARTint_off

	pop		FNDcnt
	pop		FND_En
	pop		temp
	pop		r0
	ret


SegData:
	.db $3f, $06, $5b, $4f, $66, $6d, $7d, $27, $7f, $6f, $77, $7c, $58, $5e, $79, $71, $40, $00