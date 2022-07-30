.include "m328Pdef.inc"

.org 0x00 
	rjmp RESET

.org OVF0addr
	rjmp timer0_overflow

.org INT_VECTORS_SIZE
	RESET:

.def rtmp = r16
.def reval = r17
.def rout = r18
.def rcount = r19
.def rzero = r20

.equ count = 0x25

clr rzero								; for easy compare
ldi rcount, count				; for interval

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


; enable interrupts
ldi rtmp, (1<<CS00) | (1<<CS02)
out TCCR0B, rtmp
ldi rtmp, (1<<TOIE0)
sts TIMSK0, rtmp

sei


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

timer0_overflow:
	dec rcount					; increase counter
	cpse rcount, rzero	; on overflow do not return
	reti

	ldi rcount, count		; reset counter

	inc rout
	out PORTB, rout
	reti

; vim: set sw=2 ts=2 sts=2:
