
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

    bank0()
_gsu_start:
    sub r0
    cmode

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

        define x(r1)
        define y(r2)
        define x_len(r3)
        define y_max(r4)
        define x2(r5)
        define pal2(r6)
        ibt {y}, #8
        iwt {x_len}, #(FB_WIDTH-32)/2
        iwt {x2}, #8+(FB_WIDTH-32)/2
        iwt {y_max}, #128
        iwt {pal2}, #128
-
        with {y}
        color

        ibt {x}, #16
        move r12, {x_len}
        move r13, r15
        loop
         plot

        from {y}
        add {pal2}
        color
        move {x}, {x2}
        move r12, {x_len}
        move r13, r15
        loop
         plot

        inc {y}
        with {y}
        cmp {y_max}
        bne -
         nop

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
    iwt r12, #FB_SIZE/2
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

include "../../../lib/lut/sin8.inc"
// vim:ft=snes
