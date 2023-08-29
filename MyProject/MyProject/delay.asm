delay_ms:
	call	delay1ms	
	sbiw	r25:r24, 1		; 16bit r25, r24 ������ 1����
	brne	delay_ms		; 0�� �Ǳ������� �ݺ�
	ret

delay1ms:
	; �Լ� �������� Ȱ���ϴ� �������� ���ÿ� ����(push)
	push	YL
	push	YH

	; 16MHz�̱� ������ 1ms delay�� ���ؼ��� Counter Cycle 16000�����ؾ� ��
	ldi		YL, LOW(((F_CPU/1000)-18)/4)
	ldi		YH, HIGH(((F_CPU/1000)-18)/4)

delay1ms_1:
	sbiw	YH:YL, 1
	brne	delay1ms_1

	; �Լ� �������� Ȱ���ϴ� �������� ����(pop)
	pop		YH
	pop		YL
	ret