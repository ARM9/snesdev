
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
include "../../lib/ppu.inc"
include "../../lib/mem.inc"
include "../../lib/timing.inc"
include "../../lib/stdio.inc"

    bank0() // project files
include "interrupts.asm"
//-------------------------------------

    zpage()
frame_counter:;     fill 1
    
    bss()
inidisp_mirror:;    fill 1

bg12nba_mirror:;    fill 1
bg34nba_mirror:;    fill 1
tm_mirror:;         fill 1

nmitimen_mirror:;   fill 1

//-------------------------------------

    bank0()
scope main: {
    rep #$30
    
    // upload gsu program to sram
    BlockMoveN(GSU_PRGROM, GSU_SRAM_PRG, GSU_PRGROM_SIZE)
    phk; plb
    // upload scpu program to wram
    sep #$20
    LoadWram($8000, WRAM_PRG, $8000)

    jml _gowram|WRAM_PRG
_gowram:
    jsr setupVideo

    //jsr sqrtTest
    puts("Hello world")
    Vsync()

    jsr stdout.dmaWramBufferToVram

    lda.w inidisp_mirror
    sta.w REG_INIDISP
_forever:
    bra _forever
}

scope setupVideo: {
    php
    rep #$10; sep #$20
    LoadVram(torus_sans, stdout.VRAM_TILES_ADDR, torus_sans.size)
    LoadCgram(text_pal, $00, text_pal.size)

    stdout.Init(1, 0, 0)
    lda.b #2
    jsr stdout.initBackground

    //lda #$00
    //sta REG_CGWSEL
    //lda #%00100011
    //sta REG_CGADSUB
    lda.b #$00
    sta.w REG_COLDATA

    lda.b #$00
    sta.w REG_BGMODE

    lda.w tm_mirror
    sta.w REG_TM

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

    lda.b #$0F
    sta.w inidisp_mirror

    plp
    rts
}

// GSU code
include "gsu/main.asm"

// vim:ft=snes
