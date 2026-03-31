/*
 * capteurdistance.asm
 *
 *  Created: 29/05/2023 16:17:23
 *   Author: louis
 */ 
 captcheck :						; controle de la distance 
	clr r29						; r29 a 0, le programe ne sautera plus dans captcheck au prochain appel du main
	sbi ADCSR, ADSC				; déclenche une conversion sur le capteur de distance 
	in w, ADCL					; place le signal échantillonée dans w et _w
	in _w, ADCH
	cpi _w,0
	brne stop					; si le signale est superieur ou egale a 0x0100, saut vers stop,mode off activé
	cbi ADCSR, ADSC				; désactive la conversion
	ret

stop:							
	ldi r26, 0x00				; mode off au prochain passge dans le main
	rcall LCD_home				; affiche "CHARGE ARRIVE" 
	PRINTF LCD 
	.db	"CHARGE ARRIVE   ", 0 
	ret