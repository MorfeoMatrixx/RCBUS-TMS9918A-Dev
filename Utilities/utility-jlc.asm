;
; BDOS and Miscellaneous Utility Routines for Z80 ASM under CP/M
; by Jose Luis Collado (MorfeoMatrixx), Nov-2023
; Based on original code by J.B. Langston and Wayne Wharten 
;
; Permission is hereby granted, free of charge, to any person obtaining a 
; copy of this software and associated documentation files (the "Software"), 
; to deal in the Software without restriction, including without limitation 
; the rights to use, copy, modify, merge, publish, distribute, sublicense, 
; and/or sell copies of the Software, and to permit persons to whom the 
; Software is furnished to do so, subject to the following conditions:
; 
; The above notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
; DEALINGS IN THE SOFTWARE.
;

;============================================================================
; BDOS & Miscellaneous Utility Definitions
;============================================================================
;
stksize			equ	64			; Working local stack size
;
RESTART			equ	00h			; CP/M restart vector
BDOS			equ	05h			; BDOS invocation vector (Entry Point)
IOBYTE			equ	03h			; IOBYTE address
;
FCB				equ 05Ch		; First FCB location
FCB2			equ 06Ch		; Second FCB location (Partial)
FCB_DISK 		equ FCB+0   	;  DISK NAME
FCB_FNAME   	equ FCB+1   	;  FILE NAME
FCB_FTYPE  		equ FCB+9   	;  DISK FILE TYPE (3 CHARACTERS)
FCB_RL   		equ FCB+12  	;  FILE'S CURRENT REEL NUMBER 
FCB_RECS   		equ FCB+15  	;  FILE'S RECORD COUNT (0 TO 128)
FCB_CURR   		equ FCB+32  	;  CURRENT (NEXT) RECORD NUMBER (0 TO 127)
FCB_SIZE   		equ FCB+33  	;  FCB LENGTH 
;
CMDTAIL 		equ 81			; Command Line Tail Text
CMDSIZE 		equ 80			; Command Line Tail length
;
PARAM1			equ FCB_FNAME	; 1st CL Parameter 
PARAM2			equ FCB2+1		; 2nd CL Parameter
;
; BDOS function # (Load in C)
BDOS_CONSTAT	equ	06h			; Direct Con IO & Check Stat (sub-func in E)
BDOS_CONIN		equ	01h			; Input character to A
BDOS_CONOUT		equ	02h			; Output character in E 
BDOS_CONSTR		equ 09h			; Output $-terminated string pointed by DE 
;
CR				equ 0Dh
LF				equ 0Ah
EOS				equ '$'			; End-Of-String terminator
;

;============================================================================
; Helper Routines
;
;----------------------------------------------------------------------------
; Console Output & Conversions
;
; Output A in Hex. Preserves A
HEXOUT:
    push 	af
	push    af
    rra
    rra
    rra
    rra
    call    nybhex
	ld		e,a
    call    CHROUT
    pop     af
    call    nybhex
	ld		e,a
    call    CHROUT
	pop		af
	ret

; Convert lower nybble of A to ASCII hex (also in A)
; from http://map.grauw.nl/sources/external/z80bits.html#5.1
nybhex:
    or      0F0h
    daa
    add     a, 0A0h
    adc     a, 40h
    ret

; Output a Space. Preserves A
SPACE:
	ld      e, ' '
    call    CHROUT
	ret	

; Output a New Line. Preserves A
CRLF:
    ld      e, CR
    call    CHROUT
    ld      e, LF
    call    CHROUT
	ret	

; Output ASCII character in E. Preserves A
CHROUT:
	push	af
    ld      c, BDOS_CONOUT
    call    BDOS
	pop		af
	ret

; Output $-terminated String pointed to by DE
STROUT:
    ld      c, BDOS_CONSTR
    call    BDOS
	ret

; Check for Keypress and clear Z flag if pressed
KEYPRESS:
    ld      c, BDOS_CONSTAT
    ld      e, 0FFh
    call    BDOS
    or      a
    ret
		
;----------------------------------------------------------------------------
; BCD Conversion Routines
;
;	A(BCD) => A(BIN)   [00H..99H] -> [0..99]
;
BCD2BYTE:
	PUSH	BC
	LD		C,A
	AND		0F0h
	SRL		A
	LD		B,A
	SRL		A
	SRL		A
	ADD		A,B
	LD		B,A
	LD		A,C
	AND		0Fh
	ADD		A,B
	POP		BC
	RET
;
;	A(BIN) =>  A(BCD)	[0..99] => [00H..99H]
;
BYTE2BCD:
	PUSH 	BC
	LD		B,10
	LD		C,-1
byte2bcd1:
	INC		C
	SUB		B
	JR		NC,byte2bcd1
	ADD		A,B
	LD		B,A
	LD		A,C
	ADD		A,A
	ADD		A,A
	ADD		A,A
	ADD		A,A
	OR		B
	POP		BC
	RET

;
;----------------------------------------------------------------------------
; Convert Binary value in A to ASCII Hex characters in DE
;
BIN2AHEX:
	ld		d,a			; save A in D
	call	NIB2AHEX	; convert low nibble of A to hex
	ld		e,a			; save it in E
	ld		a,d			; get original value back
	rlca				; rotate high order nibble to low bits
	rlca
	rlca
	rlca
	call	NIB2AHEX	; convert high nibble of A to hex
	ld		d,a			; save it in D
	ret					; done

;
; Convert low nibble of A to ASCII Hex in A
;
NIB2AHEX:
	and		$0F	     	; low nibble only
	add		a,$90
	daa	
	adc		a,$40
	daa	
	ret
;
;----------------------------------------------------------------------------
; Convert ASCII Hex characters in HL to Binary value in A
;
; Converts two ASCII characters (representing two hexadecimal digits in HL)
;  to one byte of binary data in A. 
;
AHH2BIN:
	LD A, 	L 			; GET LOW CHARACTER 
	CALL 	AH2BIN 		; CONVERT IT TO HEXADECIMAL 
	LD B, 	A 			; SAVE HEX VALUE IN B 
	LD A, 	H 			; GET HIGH CHARACTER 
	CALL 	AH2BIN		; CONVERT IT TO HEXADECIMAL 
	RRCA 
	RRCA 
	RRCA 
	RRCA
	OR B				; OR IN LOW HEX VALUE 
	RET 
;
AH2BIN: 				; Convert ASCII char in A to Hex Digit (Binary)
	SUB 	'0' 		; Substract ASCII offset for Numbers
	CP 		10 
	JR 		C, ah2bin1 	; Branch if A is a Decimal Digit 
	SUB 	7 			; else substract offset for Letters 
;
ah2bin1: 
	RET 
;
; >>> END <<<
