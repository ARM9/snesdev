
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
constant WRAM_PRG($7e8000)
//-------------------------------------

    bank0()
_start:
    InitSnes()

//-------------------------------------
    bank0() // libraries
include "../../lib/dma.inc"
include "../../lib/ppu.inc"
include "../../lib/mem.inc"
include "../../lib/timing.inc"
include "../../lib/stdio.inc"

    bank0() // project files
include "interrupts.asm"
include "profiler.asm"
//-------------------------------------

    zpage()
frame_counter:;     fill 1

    bss()
nmitimen_mirror:;   fill 1
gsu_scmr_mirror:;   fill 1

//-------------------------------------

    bank0()
scope main: {
    rep #$10
    sep #$20

    LoadWram($8000, WRAM_PRG, $8000)

    jsr setupVideo

    jml $7E0000|(wramMain & $ffff)
}

scope wramMain: {

    lda.b #1
    sta.w GSU_CLSR  // Set clock frequency to 21.4MHz

    lda.b #(GSU_CFGR_IRQ_MASK | GSU_CFGR_FASTMUL)
    sta.w GSU_CFGR

    stz.w GSU_SCBR

    lda.b #(GSU_SCMR_RON|GSU_SCMR_RAN) | GSU_SCMR_4BPP | GSU_SCMR_H192
    sta.w GSU_SCMR
    sta.w gsu_scmr_mirror

    stz.w GSU_RAMBR

    jsr runTests

    jsr Interrupts.init
_forever:
    wai
    bra _forever
}

scope setupVideo: {
    php
    rep #$10; sep #$20

    LoadVram(torus_sans, stdout.VRAM_TILES_ADDR, torus_sans.size)
    LoadCgram(text_pal, $00, text_pal.size)

    stdout.Init(1, 0, 0)
    stdout.InitBg(2)

    lda.b #$00
    sta.w bgmode_mirror

    lda.b #$FF
    sta.w REG_BG1VOFS
    stz.w REG_BG1VOFS
    //sta REG_BG1HOFS
    //stz REG_BG1HOFS

    dec
    sta.w REG_BG2VOFS
    stz.w REG_BG2VOFS
    //sta REG_BG2HOFS
    //stz REG_BG2HOFS

    jsr PPU.updateRegs

    lda.b #$0F
    sta.w inidisp_mirror

    plp
    rts
}

// GSU code
include "gsu/mult_test.asm"

// vim:ft=snes
