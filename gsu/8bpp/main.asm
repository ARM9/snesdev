
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
include "framebuffer.asm"
//-------------------------------------

    zpage()
frame_counter:;     fill 1

    bss()
gsu_scmr_mirror:;   fill 1
//-------------------------------------

    bank0()
main: {
    // wipe sram
    rep #$30
    BlockMoveN($7E0000, $700000, $10000)
    phk; plb
    // make screen border tile
    sep #$20
    lda.b #$00
    sta.b zp0
    FillVram($7E0000, $4000-$20, $40)
    FillVram($7E0000, $8000-$20, $40)

    LoadVram(fb_map, VRAM_FB_MAP, fb_map.size)
    LoadCgram(sfx_pal, $00, sfx_pal.size)

    LoadWram($008000, WRAM_PRG, $8000)

    jml $7E0000|(wramMain & $ffff)
}

scope wramMain: {
    sep #$20

    lda.b #GSU_CLSR_21MHZ
    sta.w GSU_CLSR  // Set clock frequency to 21.4MHz

    lda.b #(GSU_CFGR_IRQ_MASK | GSU_CFGR_FASTMUL)
    sta.w GSU_CFGR

    lda.b #FRAMEBUFFER>>10
    sta.w GSU_SCBR  // Set screen base to $702000

    lda.b #(GSU_SCMR_RON|GSU_SCMR_RAN) | GSU_SCMR_8BPP | GSU_SCMR_H160
    sta.w GSU_SCMR
    sta.w gsu_scmr_mirror

    stz.w GSU_RAMBR

    lda.b #_gsu_start>>16
    sta.w GSU_PBR

    ldx.w #_gsu_start
    stx.w GSU_R15   // GSU is booted on write to R15

    // Set up ppu
    lda.b #3
    sta.w REG_BGMODE

    lda.b #(VRAM_FB_MAP >> 8) & $FC
    sta.w REG_BG1SC

    lda.b #0
    sta.w REG_BG12NBA

    lda.b #$01
    sta.w REG_TM    // Enable BG1

    lda.b #GSU_SFR_GO
-;  bit.w GSU_SFR   // Wait for GSU to stop
    bne -

    stz.w GSU_SCMR

    LoadVram(FRAMEBUFFER, $0000, FB_SIZE)

    lda.b #$0F
    sta.w REG_INIDISP
forever:
    bra forever
}

include "gsu/main.asm"

// vim:ft=snes
