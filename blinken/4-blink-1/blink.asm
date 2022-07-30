.include "m328Pdef.inc"

.org 0x00 
	rjmp RESET

.org OC1Aaddr	
	rjmp timer1_compare

.org INT_VECTORS_SIZE
	RESET:

.def rtmp = r16
.def reval = r17
.def rout = r18

.equ toph = 0x3d
.equ topl = 0x9

; stack pointer
ldi rtmp, HIGH(RAMEND)
out SPH, rtmp
ldi rtmp, LOW(RAMEND)
out SPL, rtmp

; PortB to out
ldi rtmp, 0xFF
out DDRB, rtmp

; PortD to in
ldi rtmp, 0x00
out DDRD, rtmp

; pull ups
ldi reval, 0xFF ; reg for input eval 
out PORTD, reval	 ; use for pull up init

; init
ldi rout, 0b00000001 ; output
out PORTB, rout

;
; interrupts
;

ldi rtmp, (1<<CS12) | (1<<CS10) | (1<<WGM12)    ; clock select and mode
sts TCCR1B, rtmp		

; set top
ldi rtmp, toph
sts OCR1AH, rtmp
ldi rtmp, topl
sts OCR1AL, rtmp

ldi rtmp, (1<<OCIE1A) ; enable output compare a interrupt
sts TIMSK1, rtmp

sei

;loop: jmp loop

loop:
  in rtmp, PIND
  cpse rtmp, reval  	; skip subroutine jump if nothing happend
  jmp key
  jmp loop

key:
	com rtmp					; it is pull-up so invert it to get the button pushed
  eor rout, rtmp 	  ; toggle output at the bit triggered

  out PORTB, rout  ; write to output

wait:
  in rtmp, PIND
  cpse rtmp, reval		; wait until key is released
  rjmp wait
  rjmp loop

timer1_compare:
	inc rout
	out PORTB, rout
	reti

; vim: set sw=2 ts=2 sts=2:
