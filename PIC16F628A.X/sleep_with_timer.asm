; PIC16F628A Configuration Bit Settings
; ASM source line config statements
#include "p16f628a.inc"

; CONFIG
; __config 0xFF19
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF

;RB7 = set
;RB6 = reset
;timer_count(20ms) = d'65506'|0xFFE2
;timer_count(120ms) = d'65355'|0xFF4C
timer_countL	EQU 0xE2
timer_countH	EQU 0xFF
control_reg	EQU 0x20
self		EQU 0x01
	
	ORG	0x0000
	GOTO	setup
	
	ORG	0x0004
	BTFSC	PIR1 , TMR1IF		;check timer1 interrupt
	CALL	timer
	BTFSC	INTCON, RBIF		;check button interrupt
	CALL	button
	RETFIE
	
timer:		
	BCF	PIR1, TMR1IF		;clear timer1 interrupt flag
	BSF	INTCON, RBIE		;enable rb change interrupt
	BCF	T1CON, TMR1ON		;stop timer1
	RETURN
	
button:
	MOVF	PORTB, self		;required to clear the flag RBIF
	BCF	INTCON, RBIF		;cleaning up rb change interrupt flag
	
	BTFSS	PORTB, RB7		;checking that had interruption 
	GOTO    skip
	BTFSS	PORTB, RB6
	GOTO    skip
	RETURN
	
skip:
	BCF	INTCON, RBIE		;disable rb change interrupt
	
	BTFSS	PORTB, RB7
	INCF	PORTA			;inc porta
	BTFSS	PORTB, RB6
	CLRF	PORTA			;reset porta
	
	MOVLW	timer_countH		;set timer1 initial value
	MOVWF	TMR1H
	MOVLW	timer_countL
	MOVWF	TMR1L
	BSF	T1CON, TMR1ON		;start timer1
	RETURN
    
setup:				
	BANKSEL	CMCON
	MOVLW 0x07			;disable comparators
	MOVWF CMCON
    
	BANKSEL	TRISA
	CLRF	TRISA			;setting porta as output
	BSF	TRISB, RB7		;set rb7 (set) as input
	BSF	TRISB, RB6		;set rb6 (reset) as input
	
	BANKSEL	PCON			
	BCF	PCON, OSCF		;setting internal clock as 48kHz
	BSF	PIE1, TMR1IE		;enable timer1 interrupt
	BCF	OPTION_REG, NOT_RBPU	;enable pull-ups in portb
	
	BANKSEL	PORTA
	CLRF	PORTA			;cleaning up porta
	CLRF	PORTB			;cleaning up portb. The flag RBIF will
					;only be disabled if the portb was read
					
	CLRF	INTCON			;cleaning up intcon. After enable portb
					;pull-ups, the INTF and the RBIF flags 
					;will be enable
	
	BANKSEL	T1CON
	MOVLW	b'00111000'		;7~6|00 - unimplemented
	MOVWF	T1CON			;5~4|11 - prescalar 1:8
					;3  |1  - enable oscillator
					;2  |0  - ignored (internal clock)
					;1  |0  - internal clock
					;0  |0  - stop timer1
	
	MOVLW	b'11001000'		;7|1 - enable global interrupts
	MOVWF	INTCON			;6|1 - enable peripheral interrupts
					;5|0 - disable TMR0 interrupt
					;4|0 - disable RB0 interrupt
					;3|1 - enable RB port change interrupt
					;2|x - dont care
					;1|x - dont care
					;0|x - dont care
	
main:	SLEEP
	GOTO	main
	
	END
