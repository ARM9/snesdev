
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

    bank0()
scope gsu: {
start:
    iwt r6, #0x104
    iwt r1, #1
    jal div16x8
     nop

    bra start
     nop

    iwt r0, #128
    ibt r1, #-41
    jal div
     nop
    move r8, r2
    move r9, r3

print -1/2
print "\n"
print -1%2
print "\n"
    iwt r0, #-1
    ibt r1, #2
    jal div
     nop

    ibt r0, #-1/2
    with r2; cmp r0
    beq +
     nop
    ibt r7, #-1
+

-;  bra -
     nop
}

include "div.asm"
// vim:ft=snes
