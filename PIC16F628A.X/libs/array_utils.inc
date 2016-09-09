#include "libs/utils.inc"
	
aux	EQU	0x20
	
ASI	macro	baseAdr, index
	MOVLW	baseAdr
	MOVWF	FSR
	MOVLW	index
	ADDWF	FSR, F
	endm
	
AMOVLF	macro	baseAdr, literal, index
	ASI	baseAdr, index
	MOVLW	literal
	MOVWF	INDF
	endm
	
AMOVFF	macro	baseAdr, first, second
	ASI	baseAdr, first
	MOVFF	INDF, aux
	
	ASI	baseAdr, second
	MOVFF	aux, INDF
	endm
	
ASWAP	macro	baseAdr, first, second
	ASI	baseAdr, first	    ;w = first + second
	MOVFF	INDF, aux
	ASI	baseAdr, second
	MOVF	aux, W
	ADDWF	INDF, W		    
	
	MOVWF	aux
	ASI	baseAdr, first	    ;w = w - first
	MOVF	aux, W
	SUBWF	INDF, F
	COMF	INDF, F
	INCF	INDF		    
		
	MOVWF	aux
	ASI	baseAdr, second	    ;w = w - second
	MOVF	aux, W
	SUBWF	INDF, F
	COMF	INDF, F
	INCF	INDF	
	endm


