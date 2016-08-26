; PIC16F628A Configuration Bit Settings
; ASM source line config statements
#include "p16F628A.inc"

; CONFIG
; __config 0xFF19
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF

iCount	    EQU	d'241'
control_reg EQU	0x20
can_sleep   EQU	0x00
 
	ORG	0x0000
	GOTO	setup
	
	ORG	0x0004
	BTFSC	INTCON , T0IF
	CALL	i_tar
	BTFSC	INTCON, INTF
	CALL	button
	RETFIE
	
i_tar:		
	BCF	INTCON, T0IF	    ;clear timer interrupt flag
	BSF	INTCON, INTE	    ;enable rb0 interrupt
	BSF	control_reg, can_sleep  ;enable sleep
	RETURN
	
button:
	BCF	INTCON, INTF	    ;clear rb0 interrupt flag
	INCF	PORTA		    ;inc porta
	BCF	INTCON, INTE	    ;disable rb0 interrupt
	MOVWF	iCount		    ;set timer initial value
	MOVWF	TMR0
	BCF	control_reg, can_sleep  ;disable sleep
	RETURN
	
setup:	
	CLRF PORTA
	BANKSEL	CMCON
	MOVLW 0x07
	MOVWF CMCON
    
	BANKSEL	TRISA
	CLRF	TRISA	
	BSF	TRISB, RB0
	
	BANKSEL	OPTION_REG
	MOVLW	b'11010011'
	MOVWF	OPTION_REG
	BCF	PCON, OSCF
	MOVLW	b'10110000'
	MOVWF	INTCON
	
	BANKSEL	PORTA
	MOVLW	iCount
	MOVWF	TMR0
	BSF	control_reg, can_sleep
	
main:	BTFSC	control_reg, can_sleep
	SLEEP
	GOTO	main
	
	END
