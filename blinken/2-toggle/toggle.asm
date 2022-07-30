.include "m328Pdef.inc"

; PortB to out
ldi r16, 0xFF
out DDRB, r16

; PortD to in
ldi r16, 0x00
out DDRD, r16

; pull ups
ldi r17, 0xFF ; reg for input eval 
out PORTD, r17	 ; use for pull up init

; init
ldi r18, 0x01 ; output
out PORTB, r18


loop:
  in r16, PIND
  cpse r16, r17  	; skip subroutine jump if nothing happend
	;sbrs r16, 5
  jmp key
  jmp loop

key:
	com r16					; it is pull-up so invert it to get the button pushed
  eor r18, r16 	  ; toggle output at the bit triggered

  out PORTB, r18  ; write to output

wait:
  in r16, PIND
  cpse r16, r17		; wait until key is released
	;sbis PIND, 5
  rjmp wait
  rjmp loop

; vim: set sw=2 ts=2 sts=2:
