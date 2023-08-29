;***************************************************************************
;* File Name : "setting.inc"
;* 변수 선언 및 macro 설정
;***************************************************************************

#define F_CPU 16000000 ; CPU 16MHz
#define FND_TIME 1 ; Delay에 해당하는 시간

; 통신 속도 결정
#define BAUDRATE 57600
#define UBRR0 (F_CPU / (BAUDRATE * 16)) - 1

; Keyboard 입력
#define LF 0x0A ; Line Feed
#define CR 0x0D ; Carriage Return
#define EOS 0x00 ; End of String
#define BS 0x7F ; Back Space
#define SP 0x20 ; Spacebar

#define SetGREEN 0x1b,"[0;32m"
#define ClrCOLOR 0x1b,"[0m"

; FND, LED
#define GoStop r3

#define SREG2 r11 ; Interrupt 처리 전에 Status Register 값을 저장해두기 위한 레지스터
#define Timer0cnt r16 ; 1초에 244번 Interrupt가 발생하므로 이를 세기 위한 변수
#define temp r17

#define FND_Data r18 ; SegData의 특정 값을 위한 데이터(숫자에 대한 7SEG 표현)
#define FND_En r19 ; 7Seg의 Enable 신호
#define LEDData r20	; LEDData에 넣을 값을 위한 레지스터
#define FNDcnt r21 ; 10번(0~9까지) 반복하기 위해

#define phonecnt r7 ; phone number 출력을 위한 레지스터

; ADC Data
#define ADdataL r12 ; ADC Data Low
#define ADdataH r13 ; ADC Data High

; Temperature
#define ATS75_ADDR_W 0x98 ; i2c 주소 7bit + Write 1bit(10011000)
#define ATS75_ADDR_R 0x99 ; i2c 주소 7bit + Read 1bit(10011001)
#define ATS75_TEMP_REG 0 ; 16bit 레지스터 (Only Read)
#define ATS75_CONFIG_REG 1 ; 16bit 레지스터 (Only Read)

#define TWIdataH r14 ; 온도센서로부터 읽은 데이터의 상위 바이트 저장을 위한 레지스터
#define TWIdataL r15 ; 온도센서로부터 읽은 데이터의 하위 바이트 저장을 위한 레지스터

#define Quotient r20 ; 10진수 변환을 위한 레지스터
#define I2Cdata r21 ; 온도센서에 보낼 데이터를 위한 레지스터
#define I2Cack r22; ACK / NOACK을 위한 레지스터

; Buzzer
#define BUZ_ON 0x10	; bit4를 통해 Buzzer 출력
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
// 1옥타브
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

// 2옥타브
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

// 3옥타브
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

; X 레지스터 Set
.macro SETXY
	ldi		@0H, high(@1)
	ldi		@0L, low(@1)
.endmacro

; Z 레지스터 Set
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

; r0, r1, r2 레지스터 set
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
