.include "m328Pdef.inc"

ldi r16, 0xFF
out DDRB, r16

ldi r16, 0x00
out DDRD, r16

;out PORTB, r16

ldi r16, 0xFF
out PORTD, r16

loop:
  in r16, PIND
  ldi r17, 1 << PC5
  eor r16, r17
  com r16
  out PORTB, r16

  rjmp loop
;end: rjmp end
