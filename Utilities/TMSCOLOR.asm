;
; TMS9918A text mode color change program
; by J.L. Collado on Jul-2023
;
;============================================================================
;
        org $100                ; CP/M Start Address of TPA

;        jp start

start:
	ld (oldstack),sp        ; save old stack pointer
        ld sp, stacktop         ; set up local stack

;        ld hl, TmsFont          ; pointer to font
;        call TmsTextMode        ; initialize text mode
;
        ld a, (PARAM1)          ; First ASCII Hex digit in PARAM1
	CALL AH2BIN 		; Convert to Binary
        CP 16
        JR NC, errormsg         ; A>15 so output Error msg to console
        call TmsTextColor       ; Set Foreground (text) Color
; 

        ld a, (PARAM1+1)        ; Second ASCII Hex digit in PARAM1+1
        call AH2BIN             ; Convert to Binary
        CP 16
        JR NC, errormsg         ; A>15 so output Error msg to console
        call TmsBackground      ; Set Background Color
        jr done
;
errormsg:
        ld de, msg
        call STROUT
;
done:
        ld sp,(oldstack)        ; put stack back to how we found it
        rst 0                   ; return to CCP
;
;		
helpers:
;        include "TmsFont.asm"	        ; Font data for Text Mode
;        include "z180.asm"             ; Z180 Routines
        include "utility_jlc.asm"       ; BDOS Definitions & Utility routines
        include "tms.asm"               ; TMS9918 Video Routines

;TmsBG:
;	defb 1			; Background Color
;TmsTX:
;	defb 14		        ; Text Color
;
msg:    
        defb "TMS9918A Color Util by J.L. Collado 2023", CR, LF
        defb " Usage: 'TMSCOLOR tb' t&b are Hex digits", CR, LF
        defb " corresponding to Text & Backgrnd colors", CR, LF, EOS

oldstack:
        defw 0000h		; Old stack pointer placeholder
        defs 64			; Local 64 bytes stack space
stacktop        equ $		; Local stack top
;
; >>> END <<<
 