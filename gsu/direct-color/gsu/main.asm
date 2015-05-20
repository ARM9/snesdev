
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

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
    bcs dont_draw
    nop
        ibt r0, #$ff
        jal fillScreen
        nop

        ibt r0, #$ff // color

        ibt r4, #2 // y coord
        ibt r9, #20 // yloop
    _y_loop:
        ibt r3, #2 // x coord
        ibt r8, #13 // xloop
        _x_loop:
            ibt r5, #8
            ibt r6, #8
            jal drawRect
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

        bra gsu_main
        nop
dont_draw:

    stop
    nop

    bra gsu_main
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
