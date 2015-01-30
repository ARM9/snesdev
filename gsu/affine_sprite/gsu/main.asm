
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

    sram0()
theta:; fill 2 // 8.8 fixed

    bank0()
_gsu_start:
    iwt r10, #$300

    ibt r0, #lut.sin8>>16
    romb
    move r14, r14

    ibt r0, #GSU_POR_OBJ// | GSU_POR_DITHER // set cmode to obj (ppu sprite)
    cmode

    AlignCache()
    cache
scope gsu_main: {
    sub r0
    jal fillScreen
    dec r0
    nop

    lms r0, (theta)
    inc r0
    lob
    sbk

    ibt r0, #$13
    color

    ibt r1, #0
    ibt r2, #1
    iwt r12, #32
    move r13, {pc}
L1:
    loop
    plot

    iwt r3, #$88
    iwt r4, #64
    iwt r9, #ball.chr
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

    iwt r3, #$20
    iwt r4, #$
    iwt r12, #$5400/2
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
insert ball,"../gfx/ball.img.bin"

// vim:ft=snes
