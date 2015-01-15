
macro seek(variable offset) {
    origin ((offset & $7f0000) >> 1) | (offset & $7fff)
    base offset
}

    arch snes.cpu
include "segments.inc"
include "header.inc"
include "../../lib/snes_regs.inc"
include "../../lib/zpage.inc"
    bank0()
constant _STACK_TOP($2ff)
include "../../lib/snes_init.inc"

include "assets.asm"

    bank0()
_start:
    InitSnes()

//-------------------------------------
    bank0()
include "../../lib/ppu.inc"
include "../../lib/mem.inc"
include "../../lib/timing.inc"
include "interrupts.asm"
include "spc_upload.asm"
//-------------------------------------

    zpage()
frame_counter:;     fill 1

    bss()
inidisp_mirror:;    fill 1
gsu_scmr_mirror:;   fill 1
//-------------------------------------

    bank0()
main: {
    // make screen border tile
    rep #$10
    sep #$20
    
    lda #$00
    jsl LoadSPC

    lda.b #$1B
    stz.w REG_CGADD
    sta.w REG_CGDATAW
    sta.w REG_CGDATAW
    lda.b #$0F
    sta.w REG_INIDISP

    lda.b #$81
    sta.w REG_NMITIMEN
    cli
_forever:
    wai
    bra _forever
}

// vim:ft=snes
