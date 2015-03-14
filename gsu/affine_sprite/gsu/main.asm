
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

    sram0()
theta:; fill 2 //

    bank0()
_gsu_start:
    iwt r10, #$300

    ibt r0, #lut.sin8>>16
    romb

    ibt r0, #GSU_POR_OBJ// | GSU_POR_DITHER // set cmode to obj (ppu sprite)
    cmode

    AlignCache()
    cache
scope gsu_main: {
    sub r0
    jal fillScreen
    //dec r0
    nop

    lms r0, (theta)
    inc r0
    lob
    sbk

    move r3, r0
    iwt r4, #64
    iwt r5, #ball.chr
    jal drawRotatedSprite
    nop

    rpix // flush pixel cache

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

    iwt r3, #$2000
    iwt r12, #$5400/8
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

// vim:ft=snes
