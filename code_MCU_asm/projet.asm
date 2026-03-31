
; created: 17/05/2023 09:48:04
; Author : louis
; module main

.include "definitions.asm"		; register/constant definitions
.include "macros.asm"			; macro definitions


; === interrupt table ===

.org 0
	rjmp reset 
.org OVF0addr
	rjmp overflow0				


; === interrupt service routines===
overflow0: 
	com r29						; capteur de distance activée lorsque r29 =	0xff	  
	INVP PORTB, 1				; clignotement de la led 1
	reti

; === Initialisation===
reset:
	LDSP RAMEND					; Initialise le stack pointeur
	clr r29						; eteint le capteur 
	clr R26						; Initialise en mode off
	OUTI DDRD, 0xff				; PORTD en sortie, moteur
	sbi DDRE,SPEAKER			; BUZZER en sortie,
	OUTI DDRB,0xff				; PORTB en sortie, 
	OUTI PORTB,0xff				; eteit les led
	OUTI TIMSK,(1<<TOIE0)		; Overflow 0 autorisé
	OUTI ASSR, (1<<AS0)			; selection de l'orloge externe 
	OUTI TCCR0,3				; prescaleur = 32, overflow toute les 0.25secondes

	OUTI ADCSR, (1<<ADEN) + 6	; Initialisation du convertisseur analogique + PS = CK/64
	OUTI ADMUX,3				;
	
	.equ T1=1810				; T1 = frequence télécommande
	.equ konst=0x0100			; palier capteur de distance

	rcall LCD_init				; initialise l'ecran lcd
	rjmp main					; saut vers le main


.include "motor.asm"
.include "lcd.asm"				
.include "printf.asm"
.include "telecommande.asm"
.include "capteurdistance.asm"
.include "buzzer.asm"

;=== programme principale===
main :
	sbrs r29,0					; verification de l'overflow timer 0
	rcall captcheck
	CLR2 b1, b0					; clear 2-byte register
	ldi b2,14					; load bit counter
	WP1 PINE, IR				; wait if PIN= 1

	WAIT_US (3*T1/4)			; wait tree quarter period
	
loop :
	P2C PINE, IR				; move pin to carry (P2C)
	ROL2 b1, b0					; role carry into 2-byte register 
								; >reg
	WAIT_US (T1-4)				; wait a bite periode
								; >(- compensation)
	DJNZ b2, loop				; decrement and jump if 
								; >Not zero

	TOUCHE_COMPAR 115, power
	cpi r28,1					; vérifie le flag qui indique si l'utilisateur a presser on ou off
	breq mode_check
	TOUCHE_COMPAR 110, moins	
mode_check:
	cpi r26, 0x00				; vérifie si le flag qui indique si le programme est en on ou off
	breq main
	
on1:
	
	TOUCHE_COMPAR 110, moins
	TOUCHE_COMPAR 111, plus 
	TOUCHE_COMPAR 126, un 
	TOUCHE_COMPAR 125, deux 	
	TOUCHE_COMPAR 124, trois 
	rjmp main
	




	