
macro seek(variable offset) {
    origin ((offset & $7f0000) >> 1) | (offset & $7fff)
    base offset
}

    arch snes.cpu
include "segments.inc"
include "header.inc"
include "../../lib/snes_regs_dsp1.inc"
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
include "../../lib/hdma.inc"
include "interrupts.asm"
include "joypad.asm"
include "dsp-1.asm"

include "camera.asm"
include "player.asm"
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

    lda.b #DSP_BANK; pha; plb

    Joypad.Init(1)

    jsr initVideo

    jsr Camera.init
    jsr Player.init
    jsr initMatrixHdma
    jsr initBgHdma

    jsr Interrupts.init

_forever:
    rep #$30
    jsr dspUpdateProjection
    jsr dspUpdateMatrixTable
    jsr Player.update
    jsr Camera.update
    wai
    bra _forever
}

scope initVideo: {
    php
    rep #$10; sep #$20

    LoadLoVram(koop.map7, $0000, koop.map7.size)
    LoadHiVram(koop.chr7, $0000, koop.chr7.size)
    LoadCgram(koop.pal, 0, koop.pal.size)

    lda.b #$00
    sta.w REG_BG1SC
    lda.b #$4000>>10
    sta.w REG_BG2SC
    sta.w REG_BG3SC
    sta.w REG_BG4SC
    lda.b #($4000>>12)<<8
    sta.w REG_BG12NBA
    sta.w REG_BG34NBA

    lda.b #$07
    sta.w REG_BGMODE

    lda.b #$01
    sta.w REG_TM

    // set mode7 stuff
    lda.b #$C0
    sta.w REG_M7SEL

    lda.b #$05
    stz.w REG_M7A
    sta.w REG_M7A
    stz.w REG_M7D
    sta.w REG_M7D

    lda.b #$0F
    sta.w inidisp_mirror
    plp
    rts
}

// vim:ft=bass
