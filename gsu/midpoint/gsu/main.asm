
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
        ibt r0, #0
        jal fillScreen
        nop

        ibt r12, #8
        move r13, r15
//-
        lms r0, (line_x)
        move r5, r0
        lsr #2
        color
        move r0, r5
        with r5; and #15
        with r5; add #9
        lsr #4
        with r5; add r0

        ibt r3, #127
        ibt r4, #99
        jal drawCircle
        nop

        lms r0, (line_x)
        move r5, r0
        lsr #2
        color
        move r0, r5
        with r5; and #15
        with r5; add #9
        lsr #4
        with r5; add r0

        ibt r3, #85
        ibt r4, #79
        jal drawCircle
        nop

        jal updateCoords
        nop

        loop
        nop

        rpix // flush pixel cache

        stop
        nop

        bra gsu_main
        nop
dont_draw:

    jal updateCoords
    nop

    stop
    nop

    bra gsu_main
    nop
}

scope updateCoords: {
    lms r0, (line_x)
    inc r0
    lob
    sbk

    lms r0, (line_y)
    inc r0
    lob
    
    ret
    sbk
}
scope fillScreen: {
// returns: void
// args:
//  r0 = fill value
// vars:
//  r3 = screen base
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

include "midpoint.asm"
// vim:ft=bass
