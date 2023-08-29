;***************************************************************************
;* File Name : "setting.inc"
;* ���� ���� �� macro ����
;***************************************************************************

#define F_CPU 16000000 ; CPU 16MHz
#define FND_TIME 1 ; Delay�� �ش��ϴ� �ð�

; ��� �ӵ� ����
#define BAUDRATE 57600
#define UBRR0 (F_CPU / (BAUDRATE * 16)) - 1

; Keyboard �Է�
#define LF 0x0A ; Line Feed
#define CR 0x0D ; Carriage Return
#define EOS 0x00 ; End of String
#define BS 0x7F ; Back Space
#define SP 0x20 ; Spacebar

#define SetGREEN 0x1b,"[0;32m"
#define ClrCOLOR 0x1b,"[0m"

; FND, LED
#define GoStop r3

#define SREG2 r11 ; Interrupt ó�� ���� Status Register ���� �����صα� ���� ��������
#define Timer0cnt r16 ; 1�ʿ� 244�� Interrupt�� �߻��ϹǷ� �̸� ���� ���� ����
#define temp r17

#define FND_Data r18 ; SegData�� Ư�� ���� ���� ������(���ڿ� ���� 7SEG ǥ��)
#define FND_En r19 ; 7Seg�� Enable ��ȣ
#define LEDData r20	; LEDData�� ���� ���� ���� ��������
#define FNDcnt r21 ; 10��(0~9����) �ݺ��ϱ� ����

#define phonecnt r7 ; phone number ����� ���� ��������

; ADC Data
#define ADdataL r12 ; ADC Data Low
#define ADdataH r13 ; ADC Data High

; Temperature
#define ATS75_ADDR_W 0x98 ; i2c �ּ� 7bit + Write 1bit(10011000)
#define ATS75_ADDR_R 0x99 ; i2c �ּ� 7bit + Read 1bit(10011001)
#define ATS75_TEMP_REG 0 ; 16bit �������� (Only Read)
#define ATS75_CONFIG_REG 1 ; 16bit �������� (Only Read)

#define TWIdataH r14 ; �µ������κ��� ���� �������� ���� ����Ʈ ������ ���� ��������
#define TWIdataL r15 ; �µ������κ��� ���� �������� ���� ����Ʈ ������ ���� ��������

#define Quotient r20 ; 10���� ��ȯ�� ���� ��������
#define I2Cdata r21 ; �µ������� ���� �����͸� ���� ��������
#define I2Cack r22; ACK / NOACK�� ���� ��������

; Buzzer
#define BUZ_ON 0x10	; bit4�� ���� Buzzer ���
#define BUZ_OFF 0x00

#define DO			17
#define RE			43
#define MI			66
#define FA			77
#define SOL			97
#define RA			114
#define SI			127
#define DDO			137
#define EndSong		0

#define BUZMode		r6
#define	ToneSong	r8

; Piano Code
// 1��Ÿ��
#define C 17
#define CS 30
#define D 43
#define DS 55
#define E 66
#define F 77
#define FS 87
#define G 97
#define GS 105
#define A 114
#define AS 122
#define B 127

// 2��Ÿ��
#define CC 137
#define CCS 143
#define DD 149
#define DDS 155
#define EE 161
#define FF 166
#define FFS 171
#define GG 176
#define GGS 181
#define AA 185
#define AAS 189
#define BB 193

// 3��Ÿ��
#define CCC 196
#define CCCS 200
#define DDD 203
#define DDDS 206
#define EEE 209
#define FFF 211
#define FFFS 214
#define GGG 216
#define GGGS 218
#define AAA 220
#define AAAS 222
#define BBB 224

; Stack Pointer Set
.macro SETSP
	ldi		r24, low(@0)
	out		SPL, r24
	ldi		r24, high(@0)
	out		SPH, r24
.endmacro

; X �������� Set
.macro SETXY
	ldi		@0H, high(@1)
	ldi		@0L, low(@1)
.endmacro

; Z �������� Set
.macro SETZ
	ldi		ZH, HIGH(2*@0)
	ldi		ZL, LOW(2*@0)
.endmacro

; Delay Set
.macro DELAYMS
	ldi		r25, HIGH(@0);
	ldi		r24, LOW(@0);
	rcall	delay_ms;
.endmacro

; r0, r1, r2 �������� set
.macro SET_Register_R0R1R2
	clr		r0
	ldi		temp, 0x01
	mov		r1, temp
	ldi		temp, 0xff
	mov		r2, temp
.endmacro

; Digit4 Set
.macro SETDigit4
	SETXY X, digit4

	ldi		temp, @0
	st		X+, temp		
	ldi		temp, @1
	st		X+, temp		
	ldi		temp, @2
	st		X+, temp		
	ldi		temp, @3
	st		X+, temp
.endmacro

; PutChar
.macro PUTC
	ldi		r24, @0
	rcall	PutChar
.endmacro

; Print Program Memory's String
.macro PRINT
	SETZ	@0
	rcall	PutString
.endmacro

; X, Y, Z register Pointer Increase
.macro ADDI16
	subi	@0H, -HIGH(@1)
	subi	@0L, -LOW(@1)
.endmacro