
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

    bank0()
_gsu_start:

    AlignCache()
    cache
scope gsu_main: {
    lms r0, (framebuffer_status) // check if framebuffer dma has completed
    ror
    bcc draw
     nop
    iwt r15, #dont_draw
     nop
draw:
        ibt r0, #$ff
        jal fillScreen
        nop

        sub r0
        cmode
        ibt r0, #2
        color

        iwt r1, #10
        iwt r2, #12
        iwt r3, #200
        iwt r4, #260
        jal drawLine
         nop

        //define x(r1)
        //define y(r2)
        //define x_max(r3)
        //define y_max(r4)
        //ibt {y}, #0
        //iwt {x_max}, #224
        //iwt {y_max}, #64
//-
        //with {y}
        //color

        //ibt {x}, #0
        //move r12, {x_max}
        //move r13, r15
        //loop
        //plot

        //inc {y}
        //with {y}
        //cmp {y_max}
        //bne -
         //nop

        rpix // flush pixel cache

        stop
        nop

        iwt r15, #gsu_main
         nop
dont_draw:

    stop
    nop

    iwt r15, #gsu_main
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

if pc()-gsu_main > 512 {
warning "program too big for cache"
}

include "bresenham.asm"
include "../../../lib/lut/sin8.inc"
// vim:ft=snes
