# TMSCOLOR.asm
CP/M program to set Text & Background color for TMS9918A allready configured in Text Mode (Default after CP/M boot).
Can be used with the TMS9918A video card set as default Console (VDU).
Intended to be compiled with SJASM cross-compiler on a PC (https://github.com/Konamiman/Sjasm)

# TMSCOLOR.COM
Pre-compiled binary for CP/M.
```
  Usage: 'TMSCOLOR tb' where t & b are Hex digits corresponding to desired Text & Background colors
  Example: 'TMSCOLOR B1' sets Light-yellow Text on a Black Background; color table can be obtained from below tms.asm equ definitions.
```

# utility-jlc.asm
Z80 Assembler utility routines required to compile TMSCOLOR

# tms.asm
Z80 Assembler routines specific for the TMS9918A chip, originally included in J.B.Langston's Github repo
(https://github.com/jblang/TMS9918A/blob/master/examples/tms.asm).
