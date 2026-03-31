/*
 * motor.asm
 *
 *  Created: 29/05/2023 16:07:30
 *   Author: louis
 */ 
 ; _s360, in a1:a0, b0 out void, mod a2,w
 ; purpose execute arbitrary rotations
 _s360 : 
	rcall servoreg_pulse		
	dec b0						
	brne _s360				
	ret							
; servoreg_pulse, in a1,a0, out servo port, mod a3,a2
; purpose generates pulse of length a1,a0
servoreg_pulse :
	WAIT_US 20000				
	MOV2 a3, a2, a1, a0			
	P1 PORTD, SERVO1			

lpssp01:
	DEC2 a3, a2					
	brne lpssp01				
	P0 PORTD, SERVO1			
	ret

.macro CA3						; appel une sous-routine avec 3 arguments
								; arguments dans a0:a1,b0
	ldi a0, low(@1)				;vitesse et sens de rotation
	ldi a1, high(@1)			;vitesse et sens de rotation
	ldi b0, @2					;angle
	rcall @0
.endmacro