;***************************************************************************
;* File Name : "Project.asm"
;* Project. Board_Test_Manager with Project
;***************************************************************************
 
#include "setting.inc"
#define	CTRL_C 0x03

#define	TMODE_LED 0x01 ; LED TESTmode를 1로 세팅
#define	TMODE_SEG1 0x02 ; SEG1 TESTmode를 2로 세팅
#define TMODE_SEGN 0x03 ; SEGN TESTmode를 3으로 세팅
#define TMODE_BUZ 0x04 ; BUZ TESTmode를 4로 세팅
#define TMODE_PHONE 0x05 ; PHONE TESTmode를 5로 세팅
#define	TMODE_PHOTO 0x06 ; PHOTO TESTmode를 6으로 세팅
#define TMODE_TEMP 0x07 ; TEMP TESTmode를 7로 세팅
#define TMODE_PROJ 0x08 ; PROJ TESTmode를 8로 세팅
#define TESTmode r23 ; 현재 TESTmode 값을 나타내는 레지스터

#define	LocationY r4 ; Audio에서 StrCmp이후 Y위치를 반환하기 위한 레지스터
#define CodeCount r9 ; 몇번째 음(Code)을 출력할것인지 Count하기 위한 레지스터
 
.CSEG
	.ORG	0x0000
	jmp		RESET

	// External Interrupt Vector Table
	.ORG	0x00A			; External interrupt 4번만 사용
	jmp		Ext_Int4		; Switch1을 눌러 Interrupt 발생 시 해당 레이블로 jmp
	jmp		Ext_Int5		; Switch2를 눌러 Interrupt 발생 시 해당 레이블로 jmp

	// Interrupt Vector Table
	.ORG	0x0014			; External interrupt 4번만 사용
	jmp		Timer2_OVF		; Interrupt에 의해 Timer에 Overflow 발생 시 Timer2_OVF 레이블로 이동
	
	.ORG	0x001C
	jmp		Timer1_OVF		; Interrupt에 의해 Timer에 Overflow 발생 시 Timer1_OVF 레이블로 이동

	.ORG	0x0020
	jmp		Timer0_OVF		; Interrupt에 의해 Timer에 Overflow 발생 시 Timer0_OVF 레이블로 이동

	.ORG	0x0024				; Interrupt Vector Table
	jmp		UART_RXInt			; RX Complete시 Interrupt 발생

	
	.ORG	0x0046

RESET:
	SETSP	RAMEND
	SET_Register_R0R1R2

	rcall	Uart_Init			; UART 통신을 위한 초기값 설정
	rcall	PrintTitle
	PUTC	CR

forever:
	rcall	PrintCmdCursor		; Cursor Print
	rcall	ReadCmd				; GetString의 역할
	rcall	CmdInterprete
	rjmp	forever

#include "UART.asm"
#include "delay.asm"

;***************************************************************************
;* CmdInterprete
;***************************************************************************
CmdInterprete:
	SETXY	Y, buffer
	SETZ	CMDList

	rcall	StrCmp			; Compare
	tst		r24				; 같으면 0
	breq	CMD_HELP
	
	ADDI16	Z, 6			; 다음 CMDList 값 가져오기
	rcall	StrCmp
	tst		r24
	breq	CMD_LED

	ADDI16	Z, 6			; 다음 CMDList 값 가져오기
	rcall	StrCmp
	tst		r24
	breq	CMD_SEG1

	ADDI16	Z, 6			; 다음 CMDList 값 가져오기
	rcall	StrCmp
	tst		r24
	breq	CMD_SEGN

	ADDI16	Z, 6			; 다음 CMDList 값 가져오기
	rcall	StrCmp
	tst		r24
	breq	CMD_PHONE

	ADDI16	Z, 6			; 다음 CMDList 값 가져오기
	rcall	StrCmp
	tst		r24
	breq	CMD_BUZ

	ADDI16	Z, 6			; 다음 CMDList 값 가져오기
	rcall	StrCmp
	tst		r24
	breq	CMD_PHOTO
	
	ADDI16	Z, 6			; 다음 CMDList 값 가져오기
	rcall	StrCmp
	tst		r24
	breq	CMD_TEMP
	
	ADDI16	Z, 6			; 다음 CMDList 값 가져오기
	rcall	StrCmp
	tst		r24
	breq	CMD_PROJ

CMD_WRONG:
	PRINT	Wrong_MSG
	SETXY	Y, buffer
	rcall	PutStringD
	PUTC	'!'
	PUTC	CR
	
	ret

CMD_HELP:
	call	HELP
	ret

CMD_LED:
	call	LED_TEST			; CTRL-C 값이 입력되었을 때 LED를 Off
	PUTC	CR
	ret

CMD_SEG1:
	call	SEG1_TEST
	PUTC	CR
	ret

CMD_SEGN:
	call	SEGN_TEST
	PUTC	CR
	ret

CMD_PHONE:
	call	PHONE_TEST
	PUTC	CR
	ret

CMD_BUZ:
	call	BUZ_TEST
	PUTC	CR
	ret

CMD_PHOTO:
	call	PHOTO_TEST
	PUTC	CR
	ret

CMD_TEMP:
	call	TEMP_TEST
	PUTC	CR
	ret

CMD_PROJ:
	call	PROJ_TEST
	PUTC	CR
	ret

CMDList:
	.db "help", EOS, EOS
	.db "led", EOS, EOS, EOS
	.db "seg1", EOS, EOS
	.db "segn", EOS, EOS
	.db "phone", EOS
	.db "buz",EOS, EOS, EOS
	.db "photo", EOS
	.db "temp", EOS, EOS
	.db "proj",EOS, EOS

#include "PrintPutty.asm"

;***************************************************************************
;* StrCmp : Compare buffer and pre-defined command
;***************************************************************************
StrCmp:
	push	YH
	push	YL
	push	ZH
	push	ZL
	push	r19
	push	r20

Compare:
	inc		LocationY
	clr		r24
	lpm		r19, Z+			; Z 가리키는 값 가져오고 포인터 증가
	ld		r20, Y+			; Y 가리키는 값 가져오고 포인터 증가
	cpi		r20, EOS		; EOS와 비교해서 동일하면 CmpDone
	breq	CmpDone

	cp		r19, r20		; 둘이 비교
	breq	Compare			; 동일하면 Compare로 branch
	ldi		r24, 1			; 다를 경우 r24에 1 저장 후 CmpDone
		
CmpDone:
	pop		r20
	pop		r19
	pop		ZL
	pop		ZH
	pop		YL
	pop		YH
	ret

;***************************************************************************
;* ReadCmd : Cmd 명령어를 입력받기
;***************************************************************************
ReadCmd:
	SETXY	Y, buffer			; Y를 buffer(DM)의 시작주소로 설정
	rcall	GetString			; PuTTy의 입력을 수신받아 버퍼에 저장하는 함수
	PUTC	CR

	ret

;***************************************************************************
;* 내부 프로그램 동작을 위한 동작 include
;***************************************************************************
#include "help.asm"
#include "led.asm"
#include "seg1.asm"
#include "segn.asm"
#include "buz.asm"
#include "Timer0.asm"
#include "phone.asm"
#include "photo.asm"
#include "temp.asm"
#include "TWI.asm"
#include "proj.asm"

;***************************************************************************
;* UART RX Interrupt
;***************************************************************************

UARTint_On:
	in		temp, UCSR0B
	ori		temp, (1<<RXCIE0)	; 1000 0000과 ori함으로써 RX Interrupt Set
	out		UCSR0B, temp
	ret

UARTint_Off:
	in		temp, UCSR0B
	andi	temp, ~(1<<RXCIE0)	; 0111 1111와 andi함으로써 RX Interrupt Disable
	out		UCSR0B, temp
	ret

UART_RXInt:
	in		SREG2, SREG			; Status Register 저장
	
	call	GetChar
	cpi		r24, CTRL_C			; CTRL_C 값 비교
	breq	Program_off			; 동일할 경우 TESTmode를 0으로 바꾸고 종료
	
	out		SREG, SREG2			; Status Register 복구
	reti

Program_off:
	clr		TESTmode
	out		SREG, SREG2			; Status Register 복구
	reti

;***************************************************************************
;* ADC Initialization
;*************************************************************************** 
ADC_Init:
	out		ADMUX, r0

	ldi		temp, 0x87	; ADEN = '1', FreeRunning = '0', PreScaler = "111"(128)
	out		ADCSRA, temp
	ret

;***************************************************************************
;* Read ADC
;***************************************************************************
Read_ADC:
	in		temp, ADCSRA
	ori		temp, $40	; Start Conversion Bit만 set
	out		ADCSRA, temp	

ADCwait:
	in		temp, ADCSRA
	sbrs	temp, ADIF
	rjmp	ADCwait

	in		ADdataL, ADCL
	in		ADdataH, ADCH
	ret


.DSEG
	.ORG	0x0100

buffer:
	.byte	80					; 최대 80바이트에 해당하는 크기의 문자열까지 가능

digit4:
	.byte	4

StoreSong:
	.byte	80