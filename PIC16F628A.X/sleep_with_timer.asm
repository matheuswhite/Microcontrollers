; PIC16F628A Configuration Bit Settings
; ASM source line config statements
#include "p16f628a.inc"

; CONFIG
; __config 0xFF19
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF


;timer_count(20ms) = d'65302'|0xFF16
;timer_count(110ms) = d'64222'|0xFADE
timer_countL	EQU 0xDE
timer_countH	EQU 0xFA
control_reg	EQU 0x20
 
	ORG	0x0000
	GOTO	setup
	
	ORG	0x0004
	BTFSC	PIR1 , TMR1IF		;check timer1 interrupt
	CALL	timer
	BTFSC	INTCON, INTF		;check button interrupt
	CALL	button
	RETFIE
	
timer:		
	BCF	PIR1, TMR1IF		;clear timer1 interrupt flag
	BSF	INTCON, INTE		;enable rb0 interrupt
	BCF	T1CON, TMR1ON		;stop timer1
	RETURN
	
button:
	BCF	INTCON, INTF		;clear rb0 interrupt flag
	INCF	PORTA			;inc porta
	BCF	INTCON, INTE		;disable rb0 interrupt
	MOVLW	timer_countL		;set timer1 initial value
	MOVWF	TMR1L
	MOVLW	timer_countH
	MOVWF	TMR1H
	BSF	T1CON, TMR1ON		;start timer1
	RETURN
	
setup:				
	BANKSEL	CMCON
	MOVLW 0x07			;disable comparators
	MOVWF CMCON
    
	BANKSEL	TRISA
	CLRF	TRISA			;setting porta as output
	BSF	TRISB, RB0		;set rb0 as input
	
	BANKSEL	PCON			
	BCF	PCON, OSCF		;setting internal clock as 48kHz
	BSF	PIE1, TMR1IE		;enable timer1 interrupt
	
	BANKSEL	T1CON
	MOVLW	b'00111000'		;7~6|00 - unimplemented
					;5~4|11 - prescalar 1:8
					;3  |1  - enable oscillator
					;2  |0  - ignored (internal clock)
					;1  |0  - internal clock
					;0  |0  - stop timer1
	
	MOVLW	b'11010000'		;7|1 - enable global interrupts
	MOVWF	INTCON			;6|1 - enable peripheral interrupts
					;5|0 - disable TMR0 interrupt
					;4|1 - enable RB0 interrupt
					;3|0 - dont care
					;2|0 - dont care
					;1|0 - dont care
					;0|0 - dont care
					
	BANKSEL	PORTA
	CLRF	PORTA			;cleaning up porta
	
main:	SLEEP
	GOTO	main
	
	END
