; PIC16F628A Configuration Bit Settings
; ASM source line config statements
#include "p16f628a.inc"

; CONFIG
; __config 0xFF19
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF

;BANK 0
EE_size	    EQU h'20'
count	    EQU h'21'
array_adr   EQU h'22'
	
;BANK 1
i	    EQU h'21'
exit	    EQU h'22'
j	    EQU h'23'
left	    EQU h'24'
right	    EQU h'25'
largest	    EQU h'26'
index	    EQU h'27'
first	    EQU	h'28'
second	    EQU	h'29'
aux	    EQU	h'2A'
	
	ORG 0x0000  
	GOTO setup
	
	ORG 0x0004
	RETFIe

	
EE_byte_read:
	BANKSEL	EECON1
	MOVWF	EEADR
	BSF	EECON1, RD
	MOVF	EEDATA, W
	RETURN
    
	
EE_data_read:
	MOVLW	h'00'		;Read the first byte in EEPRON. The first byte
	CALL	EE_byte_read	;represent the size of content in EEPRON
	BANKSEL	PORTA
	MOVWF	EE_size
	
	CLRF	count		;Clear count reg
	MOVLW	array_adr	;setting initial array address
	MOVWF	FSR
read_loop:
	INCF	count		;increment count
	
	MOVF	count, W	;Read one byte of the EEPRON
	CALL	EE_byte_read
	BANKSEL	INDF
	MOVWF	INDF
	
	INCF	FSR		;set next address of the array
	
	MOVF	count, W	;check if all data in EEPRON has been read
	SUBWF	EE_size, W
	BTFSS	STATUS, Z
	GOTO	read_loop
	RETURN
	
	
get_element:
	MOVF	array_adr, W ;set to initial position in array
	MOVWF	FSR
	MOVF	index, W     ;offset to element index
	ADDWF	FSR
	MOVF	INDF, W	     ;put the element value in W_REG
	RETURN
	
	
max_heapfy:
	MOVF	i, W	;j = i
	MOVWF	j
	
	CLRF	exit  ;exit = false
max_heapfy_loop:    
;-------------------SETUP----------------------    
	MOVF	j, W	;left = 2*j
	MOVWF	left
	RLF	left	
	
	MOVF	j, W	;right = 2*j+1
	MOVWF	right
	RLF	right
	INCF	right	
    
	MOVF	j, W	;largest = j
	MOVWF	largest	
;-------------------LEFT----------------------
	;REG >= W -> C = 1
	MOVF	left, W	    ;check if left <= EE_size
	SUBWF	EE_size, W
	BTFSS	STATUS, C
	GOTO	skip_left
	
	MOVF	left, W	    ;get A[left]
	CALL	get_element
	MOVWF	first
	
	MOVF	largest, W  ;get A[largest]
	CALL	get_element
	MOVWF	second
	
	MOVF	second, W   ;check if A[left] >= A[largest]
	SUBWF	first, W
	BTFSS	STATUS, C
	GOTO	skip_left
	
	MOVF	left, W	    ;largest = left
	MOVWF	largets
skip_left:
;-------------------RIGHT----------------------
	MOVF	right, W    ;check if right <= EE_size
	SUBWF	EE_size, W
	BTFSS	STATUS, C
	GOTO	skip_right
	
	MOVF	right, W    ;get A[right]
	CALL	get_element
	MOVWF	first
	
	MOVF	second, W   ;check if A[right] >= A[largest]
	SUBWF	first, W
	BTFSS	STATUS, C
	GOTO	skip_right
	
	MOVF	right, W    ;largest = left
	MOVWF	largets
skip_right:
;---------------------SWAP----------------------
	MOVF	j
	SUBWF	largest, W
	BTFSS	STATUS, Z
	GOTO	diff
	GOTO	equal
diff:
	MOVF	j, W    ;get A[j]
	CALL	get_element
	MOVWF	first
	
	MOVF	largest, W    ;get A[largest]
	CALL	get_element
	MOVWF	second
	
	MOVF	first, W    ;swap A[j] with A[largest]
	MOVWF	aux
	MOVF	second, W
	MOVWF	first
	MOVF	aux, W
	MOVWF	second
	
	MOVF	largest, W  ;j = largest
	MOVWF	j
	GOTO	final
equal:
	COMF	exit
final:
;------------------STOP_CHECK----------------------    
	BTFSS	exit, 0  ;while !exit
	GOTO	max_heapfy_loop
	RETURN
	
	
build_max_heap:
	RRF	EE_size, W
	MOVWF	i	    ;i <- EE_size/2
build_max_heap_loop:
	CALL	max_heapfy
    
    	DECFSZ	i	    ;for EE_size/2 to 1
	GOTO	build_max_heap_loop
	RETURN
	
	
setup:
	CALL	EE_data_read
    
main:	
	GOTO main
	    
	ORG 0x2100
	DE  0x0B, "Hello world"
	
	END