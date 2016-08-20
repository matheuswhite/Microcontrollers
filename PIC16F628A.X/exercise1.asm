; PIC16F628A Configuration Bit Settings
; ASM source line config statements
#include "p16f628a.inc"

; CONFIG
; __config 0xFF18
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF

	ORG 0x0000

ia	EQU b'00000011'   
var	EQU 0x21
var2	EQU 0x22
n	EQU d'28'
m	EQU d'245'
   
	BANKSEL TRISA
	MOVLW   ia
	MOVWF   TRISA
    
	BANKSEL TRISB
	MOVLW   b'00000000'
	MOVWF   TRISB

	BANKSEL PORTA
	MOVLW   0x07 ;Turn comparators off
	MOVWF   CMCON
	CLRF    PORTA
	CLRF    PORTB
	CLRF    var

loop:
	BTFSS   PORTA, RA0
	GOTO    resetX  
	BTFSS   PORTA, RA1
	GOTO    inc
	GOTO    loop
    
resetX: MOVLW   0x00
	MOVWF   PORTB
	GOTO    delay

inc:    INCF    PORTB
	GOTO    delay

delay:  MOVLW   n
	MOVWF   var 
count:  DECFSZ  var
	GOTO    delay2
	GOTO    loop

delay2: MOVLW   m
	MOVWF   var2    
count2: DECFSZ  var2
	GOTO    count2
	GOTO    count

	END