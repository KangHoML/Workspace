delay_ms:
	call	delay1ms	
	sbiw	r25:r24, 1		; 16bit r25, r24 값에서 1빼기
	brne	delay_ms		; 0이 되기전까지 반복
	ret

delay1ms:
	; 함수 내에서만 활용하는 레지스터 스택에 저장(push)
	push	YL
	push	YH

	; 16MHz이기 때문에 1ms delay를 위해서는 Counter Cycle 16000증가해야 함
	ldi		YL, LOW(((F_CPU/1000)-18)/4)
	ldi		YH, HIGH(((F_CPU/1000)-18)/4)

delay1ms_1:
	sbiw	YH:YL, 1
	brne	delay1ms_1

	; 함수 내에서만 활용하는 레지스터 복구(pop)
	pop		YH
	pop		YL
	ret