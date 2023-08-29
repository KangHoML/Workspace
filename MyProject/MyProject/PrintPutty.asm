;***************************************************************************
;* Print at Putty
;***************************************************************************
PrintTitle:
	PRINT	BuildTime
	PRINT	Title
	ret

PrintCmdCursor:
	PRINT	CMDcursor
	ret

CMDcursor:
	.db	SetGREEN, "CMD:>> ", ClrCOLOR, EOS, EOS

BuildTime:
	.db "Built on ",__DATE__,"  ",__TIME__,CR, EOS ;

Title:
	.db "+===================================================================+",CR
	.db "| This is an AVR Board Test                                         |",CR
	.db "| Programmed by Kang Ho (Student #: 201910775)                      |",CR
	.db "| Following commands are provided                                   |",CR
	.db "+===================================================================+",CR
	.db "| help : Display all supported command                              |",CR
	.db "| led  : LED Test                                                   |",CR
	.db "| seg1 : Single Segment Display Test                                |",CR
	.db "| segn : Multiple Segment Display Test                              |",CR
	.db "| phone: Phone Number Display Test                                  |",CR
	.db "| buz  : Buzzer Test                                                |",CR
	.db "| photo: Photo Sensor Test                                          |",CR
	.db "| temp : Temperature Sensor Test                                    |",CR
	.db "| proj : Your Project Test                                          |",CR
	.db "+===================================================================+",CR
	.db " Pressing CTRL-C terminates selected test !!!   ",CR, EOS

Wrong_MSG:
	.db "Wrong Command ......", EOS, EOS
