/*
 * telecommande.asm
 *
 *  Created: 29/05/2023 16:11:30
 *   Author: louis
 */ 
 .macro TOUCHE_COMPAR			; saute vers arg1 si arg0 = b0

	cpi b0, @0					
	in  r1,SREG
	sbrc r1,1
	rjmp @1
	clr r1
.endmacro

.macro TOUCHE_PM				; envoie un signal carré sur le Pin SERVO1 du PORTD
								; de largeur d'impulsion arg0 et saute vers arg1
	P1 PORTD, SERVO1
	WAIT_US @0
	P0 PORTD, SERVO1
	rjmp @1 
.endmacro

.macro TOUCHE_CHIFFRE			; saute vers buzzer,actionne le moteur avec arg1 comme angle

	rcall buzzer				; saute vers buzzer
	ldi b0, @0					
	CA3 _s360, 1750,@1
	rjmp main					; saute vers main
.endmacro

power:							
	rcall buzzer				; saute vers buzzer
	com r26						; inverse r26 pour passer en mode on ou off
	WAIT_MS 500					; attend 500 ms
	rcall power_affiche			; appelle power affiche


power_affiche:
	cpi r26,0					; mode OF si r26 = 0, mode ON si r26 different 
	in _sreg,SREG
	sbrc _sreg, 1
	rjmp off

on:
	sei							; active les interuptions 
	clr r28						; flag du mode off dans le main desactivé 
	rcall LCD_home				; affichage de on 
	
	PRINTF LCD 
	.db	"on              ", 0 
	rjmp on1

off:
	ldi r28,0b00000001			; flag du mode off dans le main activé 
	cli							; désactive les intéruptions 
	OUTI PORTB,0xff				; éteint les leds
	rcall LCD_home				; affichage de of
	
	PRINTF LCD 

	.db	"off             ", 0 
	rjmp main

printplus:						; affichage de "MONTE           "
	rcall LCD_home
	
	PRINTF LCD 

	.db	"MONTEE         ", 0 
	rjmp main

printmoins:						; affichage de "DESCENTE           "
	rcall LCD_home
	
	PRINTF LCD 

	.db	"DESCENTE        ", 0 
	rjmp main


; appelle une souroutine qui fais bouger le moteur et une souroutine d'affichage
plus:
TOUCHE_PM 2000, printplus

; appelle une souroutine qui fais bouger le moteur et une souroutine d'affichage
moins:
TOUCHE_PM 1000, printmoins

; appelle une souroutine qui fais bouger le moteur et "affiche quart de tour"
un: 
	rcall LCD_home
	
	PRINTF LCD 

	.db	"quart de tour   ", 0 
	TOUCHE_CHIFFRE 1, 0x07
	
; appelle une souroutine qui fais bouger le moteur et affiche "un demi tour"
deux:
	rcall LCD_home
	
	PRINTF LCD 

	.db	"un demi tour    ", 0 
	TOUCHE_CHIFFRE 2, 0x10
	
; appelle une souroutine qui fais bouger le moteur et affiche "tour complet"
trois: 
	rcall LCD_home
	
	PRINTF LCD 

	.db	"tour complet    ", 0 
	TOUCHE_CHIFFRE 3, 0x21
	
