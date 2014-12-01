// plot a simple horizontal line

    arch snes.gsu

include "../../lib/gsu/gsu.inc"

    sram0()
line_x:; fill 2
line_y:; fill 2

    bank1()
_gsu_start:
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

        lms r1, (line_x)
        iwt r12, #64 // line length
        lms r2, (line_y)

        move r13, {pc}
        loop
        plot

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
// returns: void
// args:
//  r0 = fill value
// vars:
//  r3 = screen base
// clobbers
//  r3, r12, r13
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

// vim:ft=bass
