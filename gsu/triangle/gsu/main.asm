
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

    sram0()
tri_color:
    dw 0

    bank0()
scope my_tri: {
v0:
    db 50, 50, 10
v1:
    db 75, 75, 10
v2:
    db 25, 75, 10
    constant size(pc() - my_tri)
}

_gsu_start:
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

        iwt r3, #my_tri
        jal drawTriangle
        nop

        rpix // flush pixel cache

        stop
        nop

        bra gsu_main
        nop
dont_draw:
    lms r0, (tri_color)
    inc r0
    sbk

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

include "triangle.asm"

include "../../../lib/lut/sin8.inc"
// vim:ft=snes
