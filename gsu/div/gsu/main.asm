
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

    sram0()
line_x:; fill 2
line_y:; fill 2

    bank0()
    align(8)
    db "start"
_gsu_start:
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

    ibt r0, #lut.sin8>>16
    romb

    sub r0 // fast way to set r0 = 0
    cmode // cmode = 0, see lib/snes_regs_gsu.inc for further information
    ibt r0, #12
    color

    AlignCache()
    cache
scope gsu_main: {
    lms r0, (framebuffer_status) // check if framebuffer dma has completed
    ror
    bcs dont_draw
     nop
        ibt r0, #$ff
        jal fillScreen
        nop

        iwt r0, #lut.sin8
        move r5, r0
        lms r1, (line_x)
        to r14; add r1  // r14 = sin8 + line_x
        ibt r9, #64
        from r1; add r9 // r0 = line_x + 64
        lob             // r0 &= 0xff
        to r3; getb     // r3 = [romb:r14]  sin(x)

        to r14; add r5  // r14 = r0 + sin8
        lms r2, (line_y)
        to r4; getb     // r4 = [romb:r14]  cos(x)
        jal drawLine
        nop

        rpix // flush pixel cache

        stop
        nop

        bra gsu_main
         nop
dont_draw:
    lms r0, (line_x)
    inc r0
    lob
    sbk

    lms r0, (line_y)
    inc r0
    lob
    sbk

    stop
    nop

    bra gsu_main
     nop
}

scope fillScreen: {
// in:
//  u16 r0 = fill value
// out: void
// vars:
//  u16* r3 = screen base
// clobbers:
//  r3 r12 r13
    iwt r3, #FRAMEBUFFER
    iwt r12, #FRAMEBUFFER_SIZE/2
    move r13, {pc}
-
    stw (r3)
    inc r3
    loop
    inc r3

    ret
     nop
}

include "bresenham.asm"
include "div.asm"

include "../../../lib/lut/sin8.inc"
// vim:ft=snes