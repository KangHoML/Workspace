;***************************************************************************
;* File Name : "Project.asm"
;* Project. Board_Test_Manager with Project
;***************************************************************************
 
#include "setting.inc"
#define	CTRL_C 0x03

#define	TMODE_LED 0x01 ; LED TESTmode�� 1�� ����
#define	TMODE_SEG1 0x02 ; SEG1 TESTmode�� 2�� ����
#define TMODE_SEGN 0x03 ; SEGN TESTmode�� 3���� ����
#define TMODE_BUZ 0x04 ; BUZ TESTmode�� 4�� ����
#define TMODE_PHONE 0x05 ; PHONE TESTmode�� 5�� ����
#define	TMODE_PHOTO 0x06 ; PHOTO TESTmode�� 6���� ����
#define TMODE_TEMP 0x07 ; TEMP TESTmode�� 7�� ����
#define TMODE_PROJ 0x08 ; PROJ TESTmode�� 8�� ����
#define TESTmode r23 ; ���� TESTmode ���� ��Ÿ���� ��������

#define	LocationY r4 ; Audio���� StrCmp���� Y��ġ�� ��ȯ�ϱ� ���� ��������
#define CodeCount r9 ; ���° ��(Code)�� ����Ұ����� Count�ϱ� ���� ��������
 
.CSEG
	.ORG	0x0000
	jmp		RESET

	// External Interrupt Vector Table
	.ORG	0x00A			; External interrupt 4���� ���
	jmp		Ext_Int4		; Switch1�� ���� Interrupt �߻� �� �ش� ���̺�� jmp
	jmp		Ext_Int5		; Switch2�� ���� Interrupt �߻� �� �ش� ���̺�� jmp

	// Interrupt Vector Table
	.ORG	0x0014			; External interrupt 4���� ���
	jmp		Timer2_OVF		; Interrupt�� ���� Timer�� Overflow �߻� �� Timer2_OVF ���̺�� �̵�
	
	.ORG	0x001C
	jmp		Timer1_OVF		; Interrupt�� ���� Timer�� Overflow �߻� �� Timer1_OVF ���̺�� �̵�

	.ORG	0x0020
	jmp		Timer0_OVF		; Interrupt�� ���� Timer�� Overflow �߻� �� Timer0_OVF ���̺�� �̵�

	.ORG	0x0024				; Interrupt Vector Table
	jmp		UART_RXInt			; RX Complete�� Interrupt �߻�

	
	.ORG	0x0046

RESET:
	SETSP	RAMEND
	SET_Register_R0R1R2

	rcall	Uart_Init			; UART ����� ���� �ʱⰪ ����
	rcall	PrintTitle
	PUTC	CR

forever:
	rcall	PrintCmdCursor		; Cursor Print
	rcall	ReadCmd				; GetString�� ����
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
	tst		r24				; ������ 0
	breq	CMD_HELP
	
	ADDI16	Z, 6			; ���� CMDList �� ��������
	rcall	StrCmp
	tst		r24
	breq	CMD_LED

	ADDI16	Z, 6			; ���� CMDList �� ��������
	rcall	StrCmp
	tst		r24
	breq	CMD_SEG1

	ADDI16	Z, 6			; ���� CMDList �� ��������
	rcall	StrCmp
	tst		r24
	breq	CMD_SEGN

	ADDI16	Z, 6			; ���� CMDList �� ��������
	rcall	StrCmp
	tst		r24
	breq	CMD_PHONE

	ADDI16	Z, 6			; ���� CMDList �� ��������
	rcall	StrCmp
	tst		r24
	breq	CMD_BUZ

	ADDI16	Z, 6			; ���� CMDList �� ��������
	rcall	StrCmp
	tst		r24
	breq	CMD_PHOTO
	
	ADDI16	Z, 6			; ���� CMDList �� ��������
	rcall	StrCmp
	tst		r24
	breq	CMD_TEMP
	
	ADDI16	Z, 6			; ���� CMDList �� ��������
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
	call	LED_TEST			; CTRL-C ���� �ԷµǾ��� �� LED�� Off
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
	lpm		r19, Z+			; Z ����Ű�� �� �������� ������ ����
	ld		r20, Y+			; Y ����Ű�� �� �������� ������ ����
	cpi		r20, EOS		; EOS�� ���ؼ� �����ϸ� CmpDone
	breq	CmpDone

	cp		r19, r20		; ���� ��
	breq	Compare			; �����ϸ� Compare�� branch
	ldi		r24, 1			; �ٸ� ��� r24�� 1 ���� �� CmpDone
		
CmpDone:
	pop		r20
	pop		r19
	pop		ZL
	pop		ZH
	pop		YL
	pop		YH
	ret

;***************************************************************************
;* ReadCmd : Cmd ��ɾ �Է¹ޱ�
;***************************************************************************
ReadCmd:
	SETXY	Y, buffer			; Y�� buffer(DM)�� �����ּҷ� ����
	rcall	GetString			; PuTTy�� �Է��� ���Ź޾� ���ۿ� �����ϴ� �Լ�
	PUTC	CR

	ret

;***************************************************************************
;* ���� ���α׷� ������ ���� ���� include
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
	ori		temp, (1<<RXCIE0)	; 1000 0000�� ori�����ν� RX Interrupt Set
	out		UCSR0B, temp
	ret

UARTint_Off:
	in		temp, UCSR0B
	andi	temp, ~(1<<RXCIE0)	; 0111 1111�� andi�����ν� RX Interrupt Disable
	out		UCSR0B, temp
	ret

UART_RXInt:
	in		SREG2, SREG			; Status Register ����
	
	call	GetChar
	cpi		r24, CTRL_C			; CTRL_C �� ��
	breq	Program_off			; ������ ��� TESTmode�� 0���� �ٲٰ� ����
	
	out		SREG, SREG2			; Status Register ����
	reti

Program_off:
	clr		TESTmode
	out		SREG, SREG2			; Status Register ����
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
	ori		temp, $40	; Start Conversion Bit�� set
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
	.byte	80					; �ִ� 80����Ʈ�� �ش��ϴ� ũ���� ���ڿ����� ����

digit4:
	.byte	4

StoreSong:
	.byte	80