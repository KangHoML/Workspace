;***************************************************************************
;* PROJECT
;***************************************************************************

PROJ_TEST:
	push	temp
	push	XH
	push	XL
	push	YH
	push	YL
	push	ZH
	push	ZL

	ldi		TESTmode, TMODE_PROJ

Check_PROJ:
	PRINT	ProjLetter
	call	PRINTCmdCursor
	call	ReadCmd

	SETXY	Y, buffer
	SETZ	ProjList
	
	; CTRL_C 입력시 종료
	ld		temp, Y
	cpi		temp, CTRL_C
	breq	DONE_PROJ

	call	StrCmp
	tst		r24
	breq	Piano

	ADDI16	Z, 6
	call	StrCmp
	tst		r24
	breq	Audio

	PRINT	Wrong_MSG
	SETXY	Y, buffer
	call	PutStringD
	PUTC	'!'
	PUTC	CR

	rjmp	Check_PROJ

Piano:
	call	PIANO_TEST
	rjmp	Check_PROJ

Audio:
	call	AUDIO_TEST
	rjmp	Check_PROJ

DONE_PROJ:
	PUTC	CR
	call	PrintTitle

	pop		ZL
	pop		ZH
	pop		YL
	pop		YH
	pop		XL
	pop		XH
	pop		temp
	ret

CodeList:
	.db 'C',EOS,EOS,EOS,EOS,EOS
	.db "CS",EOS,EOS,EOS,EOS
	.db 'D',EOS,EOS,EOS,EOS,EOS
	.db "DS",EOS,EOS,EOS,EOS
	.db 'E',EOS,EOS,EOS,EOS,EOS
	.db 'F',EOS,EOS,EOS,EOS,EOS
	.db "FS",EOS,EOS,EOS,EOS
	.db 'G',EOS,EOS,EOS,EOS,EOS
	.db "GS",EOS,EOS,EOS,EOS
	.db 'A',EOS,EOS,EOS,EOS,EOS
	.db "AS",EOS,EOS,EOS,EOS
	.db 'B',EOS,EOS,EOS,EOS,EOS
	.db "CC",EOS,EOS,EOS,EOS
	.db "CCS",EOS,EOS,EOS
	.db "DD",EOS,EOS,EOS,EOS
	.db "DDS",EOS,EOS,EOS
	.db "EE",EOS,EOS,EOS,EOS
	.db "FF",EOS,EOS,EOS,EOS
	.db "FFS",EOS,EOS,EOS
	.db "GG",EOS,EOS,EOS,EOS
	.db "GGS",EOS,EOS,EOS
	.db "AA",EOS,EOS,EOS,EOS
	.db "AAS",EOS,EOS,EOS
	.db "BB",EOS,EOS,EOS,EOS
	.db "CCC",EOS,EOS,EOS
	.db "CCCS",EOS,EOS
	.db "DDD",EOS,EOS,EOS
	.db "DDDS",EOS,EOS
	.db "EEE",EOS,EOS,EOS
	.db "FFF",EOS,EOS,EOS
	.db "FFFS",EOS,EOS
	.db "GGG",EOS,EOS,EOS
	.db "GGGS",EOS,EOS
	.db "AAA",EOS,EOS,EOS
	.db "AAAS",EOS,EOS
	.db "BBB",EOS,EOS,EOS

;***************************************************************************
;* 프로젝트 동작을 위한 동작 include
;***************************************************************************
#include "piano.asm"
#include "audio.asm"

ProjLetter:
	.db "+===================================================================+",CR
	.db "| Project : Electronic Piano & Audio                                |",CR
	.db "+===================================================================+",CR
	.db "| piano : Electronic Piano                                          |",CR
	.db "| audio : Play Song with Keyboard Input                             |",CR
	.db "+===================================================================+",CR, EOS, EOS

ProjList:
	.db "piano", EOS
	.db "audio", EOS

PianoCode:
	.db C, CS, D, DS, E, F, FS, G, GS, A, AS, B, CC, CCS, DD, DDS, EE, FF, FFS, GG, GGS, AA, AAS, BB, CCC, CCCS, DDD, DDDS, EEE, FFF, FFFS, GGG, GGGS, AAA, AAAS, BBB
