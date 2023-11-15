## TMS9918A VRAM Memory Map Changes
Here I propose some changes to the VRAM Memory Map used in **RomWBW HBIOS** driver code, to allow direct compatibility with J.B.Langstrom's example code (run under VDU Console) and future utility programs to take advantage of Multicolor & Bitmap modes with minimum effort. 
Current code at '**tms.asm**' sets the memory map differently than the standard published in TI's documentation.

Below is a snipet from the modified **tms.asm** code showing some of the new memory map settings

### _______TMS9918 REGISTER SET ### JLC Mod for JBL compatibility & MODE II Readiness_______
```
TMS_INITVDU:
	.DB	$00		; REG 0 - SET TEXT MODE, NO EXTERNAL VID
TMS_INITVDU_REG_1:
	.DB	$D0		; REG 1 - SET 16K VRAM, ENABLE SCREEN, NO INTERRUPTS, TEXT MODE ($50 TO BLANK SCREEN)
TMS_INITVDU_REG_2:
	.DB	$0E		; REG 2 - SET PATTERN NAME TABLE TO (TMS_CHRVADDR -> $3800)
	.DB	$FF		; REG 3 - NO COLOR TABLE, SET TO MODE II DEFAULT VALUE
	.DB	$00		; REG 4 - SET PATTERN GENERATOR TABLE TO (TMS_FNTVADDR -> $0000)
	.DB	$76		; REG 5 - SPRITE ATTRIBUTE IRRELEVANT, SET TO MODE II DEFAULT VALUE
	.DB	$03		; REG 6 - NO SPRITE GENERATOR TABLE, SET TO MODE II DEFAULT VALUE
	.DB	$E1		; REG 7 - GREY ON BLACK
```

The original '**tms.asm**' file in **'\Source\HBIOS\'** of RomWBW source code distribution should be replaced with the file included here and the standard procedure to build and flash a Custom ROM should be used.
