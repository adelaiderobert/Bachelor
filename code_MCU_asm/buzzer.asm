/*
 * buzzer.asm
 *
 *  Created: 29/05/2023 16:45:41
 *   Author: louis
 */ 
 buzzer:							; emet un son
ldi r30, 50						; initialise le conteur a 30
label: 
	sbi PORTE, SPEAKER			; emission du signal carré 
	WAIT_US 1136				; largeur d'impulsion
	cbi PORTE, SPEAKER			; fin du signal
	WAIT_US 1136 
	dec r30						; dercrémentation du conteur 
	brne label					; branche si le compteur est a O
	ret