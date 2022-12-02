; Para realizar el Trabajo Pr�ctico, utilizar este template como base. 
 

.equ USART_BAUDRATE = 57600		; velocidad de datos de puerto serie (bits por segundo)
.equ F_CPU = 16000000			; Frecuencia de oscilador, Hz (Arduino UNO: 16MHz, Oscilador interno: 8MHz)
.equ div = 64
.equ timer_freq = F_CPU/div
.equ nnnn = timer_freq / 10 ; /10 equals .1 sec
.equ xxxx1 = 65536 - nnnn	; 40536 

.include "m328Pdef.inc"
.include "usart.inc"

.cseg

.org 0x0000
	rjmp	onReset
;**************************************************************
;* Punto de entrada al programa 
;**************************************************************

.org 0x0100  ; agregado para evitar solapamiento con usart.inc

onReset:
; Inicializa el "stack pointer"
	ldi		r16, LOW(RAMEND)   
  	out		spl, r16
	ldi    	r16, HIGH(RAMEND)   
	out    	sph, r16

; Inicializa el puerto serie (USART)
  	rcall  	usart_init                   
  	
; Habilitaci�n global de interrupciones
;	sei

setup:
	cbi DDRB, 0	; El puerto B[0] se tomara la entrada

; Loop infinito
mainLoop:
	ldi r20, 1<<ICF1		; para borrar las interrupciones pendientes
	out TIFR1, r20	; clear ICF1 flag
	ldi r20, 0b11000011
	sts TCCR1B, r20; set capture on rising, prescaling clk/64
	; basicamente este 
loop1:
	in r20, TIFR1
	sbrs r20, ICF1
	rjmp loop1 	; detecci�n flanco ascendente


	ldi r20, high(xxxx1)
	sts TCNT1H, r20
	ldi r20, low(xxxx1)
	sts TCNT1L, r20	; load timer 1
	ldi r20, 1<<ICF1
	out TIFR1, r20	; clear ICF1 flag
	ldi r20, 1<<TOV1
	out TIFR1, r20	; clear TOV1 flag

	ldi r20, 0b10000011
	sts TCCR1B, r20; set capture on falling, prescaling clk/64
loop2:
	in r20, TIFR1
	sbrs r20, ICF1
	rjmp loop2 	; detecci�n flanco descendente

	sbrs r20, TOV1
	rjmp ppp
    call raya
	rjmp mainLoop
ppp:
	call punto
	rjmp mainLoop

; Esta subrutina se invoca cada vez que se recibe un dato por puerto serie
usart_callback_rx:
	call usart_tx
	ret

punto:
	ldi r16, '.'
	call usart_tx
	ret

raya:
	ldi r16, '-'
	call usart_tx
	ret





; C�digo usado solo para debug

byte:	; print de r17
	call slash
	call bit
	call bit
	call bit
	call bit
	call bit
	call bit
	call bit
	call bit
	call slash
	ret

bit:
	sbrs r17, 7
	call cero
	sbrc r17, 7
	call uno
	lsl r17
	ret

cero:
	ldi r16, '0'
	call usart_tx
	call delay
	ret

uno:
	ldi r16, '1'
	call usart_tx
	call delay
	ret

slash:
	ldi r16, '|'
	call usart_tx
	call delay
	ret

.equ n1_delay = 28
.equ n2_delay = 84
.equ n3_delay = 1	; => delay = 4 msec @ 16Mhz
delay:
	push r17
	push r18
	push r19
	LDI R17, n3_delay
	LDI R18, n2_delay
	LDI R19, n1_delay
loop_delay:
	DEC R19
	BRNE loop_delay
	DEC R18
	BRNE loop_delay
	DEC R17
	BRNE loop_delay
	pop r19
	pop r18
	pop r17
	RET