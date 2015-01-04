
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

    sram0()
theta:; fill 2 // 8.8 fixed

    bank0()
_gsu_start:
    ibt r0, #lut.sin8>>16
    romb

    ibt r0, #GSU_POR_OBJ // set cmode to obj (ppu sprite)
    cmode
    ibt r0, #12
    color

    AlignCache()
    cache
scope gsu_main: {
    lms r0, (framebuffer_status) // check if framebuffer dma has completed
    ror
    bcs dont_draw
    //nop
        sub r0
        jal fillScreen
        //sub r0
        dec r0 // r0 = $ff

        jal rotate
        nop

        rpix // flush pixel cache

        stop
        nop

        bra gsu_main
        nop
dont_draw:
    lms r0, (theta)
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

include "rotate.asm"

BlockSize(gsu_main)
include "../../../lib/lut/sin8.inc"
// vim:ft=bass
