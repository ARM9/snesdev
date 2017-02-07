
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

    bank0()
include "assets.asm"

//-------------------------------------
constant WRAM_PRG($7e8000) //relocated scpu program
//-------------------------------------

    bank0()
_start:
    InitSnes()

//-------------------------------------
    bank0()
include "../../lib/dma.inc"
include "../../lib/ppu.inc"
include "../../lib/mem.inc"
include "../../lib/timing.inc"
include "framebuffer.asm"
include "interrupts.asm"
//-------------------------------------

    zpage()
frame_counter:;     fill 1

    bss()
gsu_scmr_mirror:;   fill 1
//-------------------------------------

    bank0()
main: {
    phk; plb

    rep #$10
    sep #$20

    LoadWram($008000, WRAM_PRG, $8000)

    jml $7E0000|(wramMain & $ffff)
}

scope wramMain: {
    sep #$20

    lda.b #1
    sta.w GSU_CLSR  // Set clock frequency to 21.4MHz

    lda.b #(GSU_CFGR_IRQ_MASK | GSU_CFGR_FASTMUL)
    sta.w GSU_CFGR

    lda.b #0
    sta.w GSU_SCBR  // Set screen base to $700000

    lda.b #(GSU_SCMR_RON|GSU_SCMR_RAN) | GSU_SCMR_4BPP | GSU_SCMR_H192
    sta.w GSU_SCMR
    sta.w gsu_scmr_mirror

    stz.w GSU_RAMBR

    lda.b #gsu.start>>16
    sta.w GSU_PBR

    ldx.w #gsu.start
    stx.w GSU_R15   // GSU is booted on write to R15

    // Set up ppu
    lda.b #1
    sta.w REG_BGMODE

    lda.b #0
    sta.w REG_BG1SC

    lda.b #0
    sta.w REG_BG12NBA

    lda.b #1
    sta.w REG_TM

-
    bra -
}

include "gsu/main.asm"

// vim:ft=snes
