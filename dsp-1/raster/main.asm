
macro seek(variable offset) {
    origin ((offset & $7f0000) >> 1) | (offset & $7fff)
    base offset
}

    arch snes.cpu
include "segments.inc"
include "header.inc"
include "../../lib/snes_regs_gsu.inc"
include "../../lib/zpage.inc"
    bank0()
constant _STACK_TOP($2ff)
include "../../lib/snes_init.inc"

include "assets.asm"
//-------------------------------------

    bank0()
_start:
    InitSnes()

//-------------------------------------
    bank0()
include "../../lib/ppu.inc"
include "../../lib/mem.inc"
include "../../lib/timing.inc"
include "interrupts.asm"
include "hdma.asm"
include "dsp-1.asm"
//-------------------------------------

    zpage()
frame_counter:;     fill 1

    bss()
inidisp_mirror:;    fill 1
nmitimen_mirror:;   fill 1

//-------------------------------------

    bank0()
scope main: {
    rep #$10
    sep #$20

    lda.b #_DSP_BANK; pha; plb

    jsr setupVideo

    jsr setupCamera
    //jsr setupMatrixHDMA
    jsr setupBGHDMA

    jsr Interrupts.setupIRQ

_forever:
    wai
    bra _forever
}
scope setupVideo: {
    //a8
    //i16

    LoadLoVram(koop.map7, $0000, koop.map7.size)
    LoadHiVram(koop.chr7, $0000, koop.chr7.size)
    LoadCgram(koop.pal, 0, koop.pal.size)

    lda.b #$07
    sta.w REG_BGMODE

    // set mode7 stuff
    lda.b #$C0
    sta.w REG_M7SEL

    lda.b #$05
    stz.w REG_M7A
    sta.w REG_M7A
    stz.w REG_M7D
    sta.w REG_M7D

    sta.w REG_TM

    lda.b #$0F
    sta.w inidisp_mirror
    rts
}

// vim:ft=bass
