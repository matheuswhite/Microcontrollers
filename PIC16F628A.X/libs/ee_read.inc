#include "libs/utils.inc"

        cblock  0x20
	    count, EE_size
	endc
	
#ifndef	EE_READ	
#define	EE_READ
	
EERB	macro	EE_pos, file
	    MOVFF   EE_pos, EEADR
	    BSF	    EECON1, RD
	    MOVFF   EEDATA, file
	endm
    
EERD	macro	baseAdr
	    CLRF    count
	    EERB    count, EE_size
	    ASI	    baseAdr, count
	    
eerd_loop:
	    INCF    count
	    EERB    count, INDF
	    ASI	    baseAdr, count	    
	    
	    MOVF    count, W	;while check
	    SUBWF   EE_size, W
	    BTFSS   STATUS, Z
	    GOTO    eerd_loop
	endm
#endif