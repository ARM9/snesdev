
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
include "interrupts.asm"
include "oam.asm"
//-------------------------------------

    zpage()
frame_counter:;     fill 1

    bss()
nmitimen_mirror:;   fill 1

gsu_scmr_mirror:;   fill 1
//-------------------------------------

    bank0()
main: {
    // wipe sram
    rep #$30
    BlockMoveN($7E0000, $700000, $10000)
    phk; plb

    sep #$20

    jsr setupVideo

    LoadWram($008000, WRAM_PRG, $8000)
    LoadWram(dummy_vectors, $7E0104, dummy_vectors.size)

    jml $7E0000|(wramMain & $ffff)
}

scope wramMain: {
    rep #$10; sep #$20

    lda.b #1
    sta.w GSU_CLSR  // Set clock frequency to 21.4MHz

    lda.b #(GSU_CFGR_IRQ_MASK | GSU_CFGR_FASTMUL)
    sta.w GSU_CFGR

    lda.b #$2000>>10//FRAMEBUFFER>>10
    sta.w GSU_SCBR  // Set screen base to $702000

    lda.b #(GSU_SCMR_RON|GSU_SCMR_RAN) | GSU_SCMR_OBJ | GSU_SCMR_4BPP
    sta.w gsu_scmr_mirror
    sta.w GSU_SCMR

    stz.w GSU_RAMBR

    lda.b #_gsu_start>>16
    sta.w GSU_PBR

    ldx.w #_gsu_start
    stx.w GSU_R15   // GSU is booted on write to R15

    WaitGsuStop()

    jsr Interrupts.init

_forever:
    // turn on screen after first frame is complete
    lda.w frame_counter
    and.b #1
    beq +
        lda.b #$0F
        sta.w inidisp_mirror
+
    wai
    bra _forever
}

scope setupVideo: {
    php
    rep #$10; sep #$20
    // make screen border tile
    LoadCgram(sfx_pal, $00, sfx_pal.size)

    // sprites
    LoadCgram(ball.pal, $80, ball.pal.size)

    lda.b #$ff
    sta.b 0
    FillVram(0, 0, $2000)

    jsr OAM.init

    lda.b #$10
    sta.w tm_mirror

    plp
    rts
}

include "gsu/main.asm"

// vim:ft=snes
