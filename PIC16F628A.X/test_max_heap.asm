; PIC16F628A Configuration Bit Settings
; ASM source line config statements
#include "p16f628a.inc"
#include "libs/ee_read.inc"
#include "libs/ee_write.inc"
#include "libs/max_heap.inc"
    
; CONFIG
; __config 0xFF19
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF

baseAdr   EQU	h'2C'
size	  EQU	h'21'
	
	ORG 0x0000  
	GOTO setup
	
	ORG 0x0004
	RETFIe
	
setup:
	EERD	    baseAdr
	BMAXHEAP    baseAdr, size
	EEWD	    baseAdr, size
	GOTO	    $
	    
	ORG 0x2100
	DE  0x0B, "Hello world"
	
	END


