
macro seek(variable offset) {
    origin ((offset & $7f0000) >> 1) | (offset & $7fff)
    base offset
}

    arch snes.cpu
include "segments.inc"
include "header.inc"
include "../lib/snes_regs.inc"
    bank0()
constant _stack_top($2ff)
include "../lib/snes_init.inc"
include "assets.asm"

    bank0()
_start:
    InitSnes()

//-------------------------------------
include "../lib/ppu.inc"
//-------------------------------------

    bank0()
scope main: {
    rep #$10
    sep #$20

    LoadVram(singular_graphic, $0000, singular_graphic.size)
    LoadCgram(pal, $00, pal.size)

    lda #$80
    sta.w REG_M7A
    stz.w REG_M7A
    sta.w REG_M7D
    stz.w REG_M7D

    lda #$07
    sta.w REG_BGMODE
    lda #$01
    sta.w REG_TM

    lda #$00//2C
    sta.w REG_BG1SC
    lda #$00
    sta.w REG_BG12NBA

    lda #$81
    sta.w REG_NMITIMEN
    lda #$0f
    sta.w REG_INIDISP
_forever:
    wai
    bra _forever
}

    bank0()
scope NmiHandler: {
    zpage()
bg_x:; fill 2
    hiram()
bg_y:; fill 2

    bank0()
    jml + // Make fast
+; phb; phk; plb
    rep #$30; pha; phx; phy
    
    sep #$20
    lda.w REG_RDNMI

    rep #$20
    lda.l bg_x; inc; sta.l bg_x
    sep #$20
    sta.w REG_M7B
    stz.w REG_M7B

    rep #$20
    lda.l bg_y; inc; sta.l bg_y 
    sep #$20
    sta.w REG_M7C
    stz.w REG_M7C

    rep #$30; ply; plx; pla; plb
    rti
}

    bank0()
IrqHandler: {
    jml +
+; phb; phk; plb
    rep #$30; pha; phx; phy
    
    sep #$20
    lda.w REG_TIMEUP

    rep #$30; ply; plx; pla; plb
    rti
}

    bank1()
include "gsu/main.asm"

// vim:ft=bass
