;***************************************************************************
;* Seg1 Display with stop by CTRL-C
;***************************************************************************
SEG1_TEST:
	push	r0
	push	temp
	push	FND_En
	push	FNDcnt
	rcall	UARTInt_On			; 해당 함수(Service Routine) 내에서만 RX Interrupt 실행

	; 출력포트 C의 DDR 설정
	ldi		temp, $FF
	out		DDRC, temp		; 7Seg의 8bit를 모두 사용

	; 포트 G의 DDR 설정(4개의 7Seg이므로 하위 4bit만 필요)
	ldi		temp, $0F
	sts		DDRG, temp		; 하위 4개의 bit만 사용하므로 0F값을 저장

	ldi		TESTmode, TMODE_SEG1
	sei

Set_Loop:
	ldi		FND_En, $08		; 첫번째 7seg를 위해 FND_En에 0000 1000 저장

Check_SEG1:
	tst		TESTmode		; 0(CTRL-C 값이 입력됨)인지 체크
	breq	DONE_SEG1		; 0일 경우 SEG1 Off


SEG1_Loop:
	sts		PORTG, FND_En	; PORTG에 FND_En값 저장(몇 번째 7seg를 킬 것인지 조정) 
	ldi		FNDcnt, 10		; 10번 반복
	SETZ	SegData			; Z 레지스터에 Program Memory의 SegData의 시작주소

Loops:
	lpm		r0, Z+			; 값 가져오고 Z 레지스터의 커서 하나 증가
	out		PORTC, r0		; 가져온 값을 C 포트를 통해 출력

	DELAYMS 100				; 0.1초 Delay

	dec		FNDcnt
	brne	Loops

	lsr		FND_En			; 하나 뒤로 옮기기 위해 logistic shift right
	brne	Check_Seg1		; 0000아닐 떄 SEG1_Loop

	rjmp	Set_Loop		; 0000일 경우 Set_Loop로 이동
	
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