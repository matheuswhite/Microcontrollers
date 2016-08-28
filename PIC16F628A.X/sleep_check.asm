; PIC16F628A Configuration Bit Settings
; ASM source line config statements
#include "p16f628a.inc"

; CONFIG
; __config 0xFF19
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF

iCount	    EQU	d'241'
control_reg EQU	0x20
can_sleep   EQU	0x00
 
	ORG	0x0000
	GOTO	setup
	
	ORG	0x0004
	BTFSC	INTCON , T0IF		;check timer interrupt
	CALL	timer
	BTFSC	INTCON, INTF		;check button interrupt
	CALL	button
	RETFIE
	
timer:		
	BCF	INTCON, T0IF		;clear timer interrupt flag
	BSF	INTCON, INTE		;enable rb0 interrupt
	BSF	control_reg, can_sleep  ;enable sleep
	RETURN
	
button:
	BCF	INTCON, INTF		;clear rb0 interrupt flag
	INCF	PORTA			;inc porta
	BCF	INTCON, INTE		;disable rb0 interrupt
	MOVWF	iCount			;set timer initial value
	MOVWF	TMR0
	BCF	control_reg, can_sleep  ;disable sleep
	RETURN
	
setup:				
	BANKSEL	CMCON
	MOVLW 0x07			;disable comparators
	MOVWF CMCON
    
	BANKSEL	TRISA
	CLRF	TRISA			;setting porta as output
	BSF	TRISB, RB0		;set rb0 as input
	
	BANKSEL	OPTION_REG		
	MOVLW	b'11010011'		;7  |1   - portb pull-up disable
	MOVWF	OPTION_REG		;6  |1   - interrup in rising edge
					;5  |0   - internal clock
					;4  |1   - dont care
					;3  |0   - prescalar in timer0
					;2~0|011 - prescalar 1:16
					
	BCF	PCON, OSCF		;setting internal clock as 48kHz
	MOVLW	b'10110000'		;7|1 - enable global interrupts
	MOVWF	INTCON			;6|0 - disable peripheral interrupts
					;5|1 - enable TMR0 interrupt
					;4|1 - enable RB0 interrupt
					;3|0 - dont care
					;2|0 - dont care
					;1|0 - dont care
					;0|0 - dont care
	BANKSEL	PORTA
	CLRF	PORTA			;cleaning up porta
	MOVLW	iCount			;setting inital value of timer as iCount
	MOVWF	TMR0
	BSF	control_reg, can_sleep	;enable sleep
	
main:	BTFSC	control_reg, can_sleep
	SLEEP
	GOTO	main
	
	END
