; PIC16F628A Configuration Bit Settings
; ASM source line config statements
#include "p16f628a.inc"
#include "libs/ee_write.inc"
    
; CONFIG
; __config 0xFF19
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF

 errorlevel -207
 errorlevel -305

	cblock	0x21
	    size, baseAdr
	endc
 
	ORG	0x0000
	GOTO	setup
	    
	ORG	0x0004
	RETFIE

fill_rotine:
	variable c23 = 0
	MOVLW	baseAdr
	MOVWF	FSR
	
	MOVLF	0xAB, INDF
	INCF	FSR
	while c23 < d'8'
	    MOVLF   0xAC, INDF
	    INCF    FSR
	    c23++
	endw
	MOVLF	0xAE, INDF
	RETURN
    
setup:	
	CALL	fill_rotine
	MOVLF	0x0A, size
	EEWD	baseAdr, size
	GOTO	$
	    
	END


