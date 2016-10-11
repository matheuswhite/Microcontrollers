#include "libs/utils.inc"

        cblock  0x20
	    count
	endc

#ifndef	EE_WRITE
#define	EE_WRITE
	
EEWB	macro	EE_pos, file
	    MOVFF   EE_pos, EEADR
	    MOVFF   file, EEDATA
	    
	    BSF	    EECON1, WREN
	    BCF	    INTCON, GIE
	    BTFSC   INTCON, GIE
	    GOTO    $-2
	    
	    MOVLW   h'55'
	    MOVWF   EECON2
	    MOVLW   h'AA'
	    MOVWF   EECON2
	    BSF	    EECON1, WR
	    BSF	    INTCON, GIE
	    BCF	    EECON1, WREN
	endm
    
EEWD	macro	baseAdr, size
	    CLRF    count
	    EEWB    count, size
	    ASI	    baseAdr, count
	    
while_loop:
	    INCF    count
	    EEWB    count, INDF
	    ASI	    baseAdr, count
	    
	    MOVF    count, W	;while check
	    SUBWF   size, W
	    BTFSS   STATUS, Z
	    GOTO    while_loop
	endm
#endif
