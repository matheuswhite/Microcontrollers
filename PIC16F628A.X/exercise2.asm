; PIC16F628A Configuration Bit Settings
; ASM source line config statements
#include "p16f628a.inc"

; CONFIG
; __config 0xFF18
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF

	    ORG 0x0000
a_config    EQU	b'00000011'
opt_config  EQU	b'11010011'
i_count	    EQU	d'241'
flags	    EQU	0x20
lock_flag   EQU	0x00
	    GOTO    setup
	    
	ORG 0x0004
	BCF flags,  lock_flag
	BCF INTCON, T0IE ;disable timer interrupt
	RETFIE
	
setup:  
	BANKSEL	OPTION_REG
	MOVLW	opt_config
	MOVWF	OPTION_REG
	BCF	PCON, OSCF
	MOVLW	b'10000000'
	MOVWF	INTCON
    
	BANKSEL TRISA
	MOVLW   a_config
	MOVWF   TRISA
    
	BANKSEL TRISB
	MOVLW   b'00000000'
	MOVWF   TRISB

	BANKSEL PORTA
	MOVLW   0x07 ;Turn comparators off
	MOVWF   CMCON
	CLRF    PORTA
	CLRF    PORTB
	CLRF	flags
	
loop:
	BTFSS   PORTA, RA0
	CALL	reset_portb
	BTFSS   PORTA, RA1
	CALL	set_portb
	GOTO    loop
    
	
reset_portb:
	BTFSS	flags, lock_flag
	CLRF	PORTB
	BTFSS	flags, lock_flag
	CALL	start_timer
	BSF	lock_flag
	RETURN
	
set_portb:
	BTFSS	flags, lock_flag
	INCF	PORTB
	BTFSS	flags, lock_flag
	CALL	start_timer
	BSF	lock_flag
	RETURN
	
start_timer:
	BSF	INTCON, T0IE
	BCF	INTCON,	T0IF
	MOVLW   i_count
	MOVWF   TMR0
	RETURN
  
	END