#include "libs/utils.inc"


	cblock	0x22
	    exit, i, j, left, right
	    largest, aux
	endc
	
#ifndef	MAX_HEAP	
#define	MAX_HEAP
	
ASWAP	    macro   baseAdr, first, second
	        ASI    baseAdr, first
	        MOVFF  INDF, aux 
	        ASI    baseAdr, second
	        ADDFF  INDF, aux, 2
	    
	        ASI    baseAdr, first
	        SUBFF  aux, INDF, 2
	    
	        ASI    baseAdr, second
		SUBFF  aux, INDF, 2
	    endm

MAXHEAPFY   macro   baseAdr, size
		MOVFF   i, j
		CLRF    exit
maxheapfy_loop:
		;--SETUP--
		MOVFF	j, left
		BCF	STATUS, C
		RLF	left, F
		
		MOVFF	j, right
		BCF	STATUS, C
		RLF	right, F
		INCF	right
		
		MOVFF	j, largest
		
		;--LEFT--
		SUBFF	size, left, 0
		BTFSS	STATUS, C
		GOTO	skip_left
	
		DECF	left
		ASI	baseAdr, left
		MOVFF	INDF, aux
		INCF	left
		
		DECF	largest
		ASI	baseAdr, largest
		INCF	largest
	
		SUBFF	aux, INDF, 0
		BTFSS	STATUS, C
		GOTO	skip_left
	
		MOVFF	left, largest
skip_left:
		;--RIGHT--
		SUBFF	size, right, 0
		BTFSS	STATUS, C
		GOTO	skip_right
	
		DECF	right
		ASI	baseAdr, right
		MOVFF	INDF, aux
		INCF	right
		
		DECF	largest
		ASI	baseAdr, largest
		INCF	largest
	
		SUBFF	aux, INDF, 0
		BTFSS	STATUS, C
		GOTO	skip_right
	
		MOVFF	right, largest
skip_right:
		;--SWAP
		SUBFF	largest, j, 0
		BTFSS	STATUS, Z
		GOTO	diff
		GOTO	equal
diff:
		DECF	j
		DECF	largest
		ASWAP	baseAdr, j, largest
		INCF	j
		INCF	largest
	
		MOVFF	largest, j
		GOTO	final
equal:
		COMF	exit
final:
		;--STOP_CHECK    
		BTFSS	exit, 0
		GOTO	maxheapfy_loop
	    endm
	    
BMAXHEAP    macro   baseAdr, size
		BCF	STATUS, C
		RRF	size, W
		MOVWF   i
bmaxheap_loop:
		MAXHEAPFY  baseAdr, size
	    
		DECFSZ  i
		GOTO    bmaxheap_loop
	endm
#endif