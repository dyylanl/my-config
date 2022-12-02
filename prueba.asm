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
	out TIFR1, r20	        ; clear ICF1 flag
	ldi r20, 0b11000011		; r20 = 11000011
	sts TCCR1B, r20         ; configura la captura en ascendente, prescaling clk/64
loop1:
	in r20, TIFR1           ; r20 = TIMER1
	sbrs r20, ICF1			; if r20[ICF1] = 1 => Salta
	rjmp loop1 				; deteccion flanco ascendente

	ldi r20, high(xxxx1)	; Cargo el timer 1
	sts TCNT1H, r20			; Cargo el timer 1
	ldi r20, low(xxxx1)		; Cargo el timer 1
	sts TCNT1L, r20			; Cargo el timer 1
	ldi r20, 1<<ICF1		; r20 = 0		
	out TIFR1, r20			; clear ICF1 flag
	ldi r20, 1<<TOV1		; r20 = 0
	out TIFR1, r20			; clear TOV1 flag
	ldi r20, 0b10000011		; r20 = 10000011
	sts TCCR1B, r20			; configura la captura en caida, prescaling clk/64
loop2:
	call raya_baja
	in r20, TIFR1			; r20 = timer
	sbrs r20, ICF1			; if(r20[ICF1] = 1) => SALTA
	rjmp loop2 				; detecci�n flanco descendente

	sbrs r20, TOV1			; if (r20[TOV1] = 1) => SALTA
	call raya_baja			; imprimo un punto
    call raya_alta			; imprimo una raya
	rjmp mainLoop

; Esta subrutina se invoca cada vez que se recibe un dato por puerto serie
usart_callback_rx:
	call usart_tx
	ret

raya_baja:
	ldi r16, '_'
	call usart_tx
	ret

raya_alta:
	ldi r16, '-'
	call usart_tx
	ret