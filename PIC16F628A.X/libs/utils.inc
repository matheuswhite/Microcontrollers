MOVLF	macro	literal, file
	MOVLW	literal
	MOVWF	file
	endm
	
MOVFF	macro	first, second
	MOVF	first, W
	MOVWF	second
	endm
	
SWAP	macro	first, second
	MOVF	first, W	;w = first + second
	ADDWF	second, W	
	
	SUBWF	first, F	;w = w - first
	COMF	first
	INCF	first		
	
	SUBWF	second, F	;w = w - second
	COMF	second
	INCF	second		
	endm
	
SETBANK   macro   bank
	    if bank == 0x00
		BANKSEL h'00'
	    else if bank == 0x01
		BANKSEL h'80'
	    endif
	    if bank == 0x02
		BANKSEL h'100'
	    endif
	    if bank == 0x03
		BANKSEL h'180'
	    endif
	    endm    
	    