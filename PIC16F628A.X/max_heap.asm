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
exit	    EQU h'20'
i	    EQU h'21'
j	    EQU h'22'
left	    EQU h'23'
right	    EQU h'24'
largest	    EQU h'25'
index	    EQU h'26'
first	    EQU	h'27'
second	    EQU	h'28'
aux	    EQU	h'29'
index2	    EQU	h'2A'
	
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
	BANKSEL	PORTA
	MOVWF	INDF
	
	INCF	FSR		;set next address of the array
	
	MOVF	count, W	;check if all data in EEPRON has been read
	SUBWF	EE_size, W
	BTFSS	STATUS, Z
	GOTO	read_loop
	RETURN
	
	
swap_elements:
	CALL	get_element	;get first element
	MOVWF	first
	MOVF	index, W	;save index1 in aux
	MOVWF	aux		
	MOVF	index2, W	;get second element
	MOVWF	index
	CALL	get_element	
	MOVWF	second
	MOVF	aux, W		;restore index1
	MOVWF	index
	
	BANKSEL	PORTA	    ;put second element in index1
	MOVLW	array_adr
	MOVWF	FSR
	BANKSEL	TRISA
	MOVF	index, W
	ADDWF	FSR
	MOVF	second, W
	MOVWF	INDF
	
	BANKSEL	PORTA	    ;put first element in index2
	MOVLW	array_adr
	MOVWF	FSR
	BANKSEL	TRISA
	MOVF	index2, W
	ADDWF	FSR
	MOVF	first, W
	MOVWF	INDF
	
	RETURN
    
	
get_element:
	BANKSEL	PORTA
	MOVLW	array_adr ;set to initial position in array
	MOVWF	FSR
	BANKSEL	TRISA
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
	BCF	STATUS, C
	RLF	left	
	
	MOVF	j, W	;right = 2*j+1
	MOVWF	right
	BCF	STATUS, C
	RLF	right
	INCF	right	
    
	MOVF	j, W	;largest = j
	MOVWF	largest	
;-------------------LEFT----------------------
	;REG >= W -> C = 1
	MOVF	left, W	    ;check if left <= EE_size
	BANKSEL	PORTA
	SUBWF	EE_size, W
	BANKSEL	TRISA
	BTFSS	STATUS, C
	GOTO	skip_left
	
	MOVF	left, W	    ;get A[left]
	MOVWF	index
	DECF	index
	CALL	get_element
	MOVWF	first
	
	MOVF	largest, W  ;get A[largest]
	MOVWF	index
	DECF	index
	CALL	get_element
	MOVWF	second
	
	MOVF	second, W   ;check if A[left] >= A[largest]
	SUBWF	first, W
	BTFSS	STATUS, C
	GOTO	skip_left
	
	MOVF	left, W	    ;largest = left
	MOVWF	largest
skip_left:
;-------------------RIGHT----------------------
	MOVF	right, W    ;check if right <= EE_size
	BANKSEL	PORTA
	SUBWF	EE_size, W
	BANKSEL	TRISA
	BTFSS	STATUS, C
	GOTO	skip_right
	
	MOVF	right, W    ;get A[right]
	MOVWF	index
	DECF	index
	CALL	get_element
	MOVWF	first
	
	MOVF	largest, W  ;get A[largest]
	MOVWF	index
	DECF	index
	CALL	get_element
	MOVWF	second
	
	MOVF	second, W   ;check if A[right] >= A[largest]
	SUBWF	first, W
	BTFSS	STATUS, C
	GOTO	skip_right
	
	MOVF	right, W    ;largest = left
	MOVWF	largest
skip_right:
;---------------------SWAP----------------------
	MOVF	j, W
	SUBWF	largest, W
	BTFSS	STATUS, Z
	GOTO	diff
	GOTO	equal
diff:
	MOVF	j, W    ;swap A[j] with A[largest]
	MOVWF	index
	DECF	index
	MOVF	largest, W
	MOVWF	index2
	DECF	index2
	CALL	swap_elements
	
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
	BANKSEL	PORTA
	BCF	STATUS, C
	RRF	EE_size, 0
	BANKSEL	TRISA
	MOVWF	i	    ;i <- EE_size/2
build_max_heap_loop:
	CALL	max_heapfy
	
	BANKSEL	TRISA
    	DECFSZ	i	    ;for EE_size/2 to 1
	GOTO	build_max_heap_loop
	RETURN
	
	
setup:
	CALL	EE_data_read
	CALL	build_max_heap
    
main:	
	GOTO main
	    
	ORG 0x2100
	DE  0x0B, "Hello world"
	
	END