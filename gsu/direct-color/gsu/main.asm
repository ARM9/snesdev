
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

macro HLine(x, y, len) {
        ibt r1, #{x}
        ibt r2, #{y}
        iwt r3, #{len}
        move r12, r3
        move r13, r15
    -
        loop
         plot
}
macro VLine(x, y, len) {
        ibt r1, #{x}
        ibt r2, #{y}
        iwt r3, #{len}
        move r12, r3
        move r13, r15
    -
        plot
        dec r1
        loop
         inc r2
}

    sram0()
line_x:; fill 2
line_y:; fill 2

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

        define columns(16)
        define rows(16)
        define h_align(FB_WIDTH/2-{columns}*8/2)
        define v_align(FB_HEIGHT/2-{rows}*8/2)

        ibt r0, #1
        color

        HLine({h_align}-1, {v_align}-1, {columns}*8+2)
        HLine({h_align}, {rows}*8+{v_align}, {columns}*8)
        VLine({h_align}-1, {v_align}, {rows}*8+1)
        VLine({columns}*8+{h_align}, {v_align}, {rows}*8+1)

        sub r0              // color
        ibt r4, #{v_align}  // y coord
        ibt r9, #16         // yloop
    _y_loop:
        ibt r3, #{h_align}  // x coord
        ibt r8, #16         // xloop
        _x_loop:
            ibt r5, #8      // tile width
            ibt r6, #8      // tile height
            jal drawRect
             nop

            inc r0

            with r3; add #8
            dec r8
            bne _x_loop
             nop
        with r4; add #8
        //with r0; add #8
        dec r9
        bne _y_loop
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
// returns: void
// args:
//  u16 r0 = fill value
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

include "rect.asm"
// vim:ft=snes
