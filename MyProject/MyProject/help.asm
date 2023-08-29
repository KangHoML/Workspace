;***************************************************************************
;* CLEAR the Screen & PrintTitle
;***************************************************************************
HELP:
	push	ZL
	push	ZH

	SETZ	CLSCode
	call	PutString
	call	PrintTitle

	pop		ZH
	Pop		ZL
	ret

CLSCode:
	.db		0x1b, 0x5b, 0x31, 0x3b, 0x31, 0x48, 0x1b, 0x5b, 0x32, 0x4a, 0x00, 0x00