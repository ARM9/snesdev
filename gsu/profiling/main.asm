
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
nmitimen_mirror:;   fill 1

//-------------------------------------

    bank0()
scope main: {
    rep #$10
    sep #$20
    
    LoadWram($8000, WRAM_PRG, $8000)
    
    jsr setupVideo
    
    rep #$20
    stdout.SetXY(5,25)
    stdout.SetPalette(1)
    sep #$20
    puts("foo bar\n")
    PrintString(long_string, 15, 27, 0)
    
    //jsr stdout.clearWramBuffer

    jsr Interrupts.init

_forever:
    //jsr runTests
    wai
    bra _forever
}

scope setupVideo: {
    LoadVram(torus_sans, stdout.VRAM_TILES_ADDR, torus_sans.size)
    LoadCgram(text_pal, $00, text_pal.size)

    lda.b #((stdout.VRAM_MAP_ADDR >> 8) & $FC)
    sta.w REG_BG1SC
    sta.w REG_BG2SC
    lda.b #(stdout.VRAM_TILES_ADDR >> 12)<<4 | ((stdout.VRAM_TILES_ADDR >> 12)&$F)
    sta.w REG_BG12NBA

    //lda #$00
    //sta REG_CGWSEL
    //lda #%00100011
    //sta REG_CGADSUB
    lda.b #$00
    sta.w REG_COLDATA

    lda.b #$00
    sta.w $2105
    lda.b #$03
    sta.w $212C

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

    rts
}

long_string:
db "Here is some text hi more text more more need to fill the entire screen sheesh this is taking forever now this is a story all about how my life got flipped turned upside down and I'd like to take a minute just sit right there, I'll tell you how I became the prince of a town called bel air.\nIn west philadelphia born and raised on the playground is",$A,"where I spent most of my days chillin out maxin' relaxin' all cool and all shootin' some b-ball outside of a school when a couple of guys that were up to no good started making trouble in my neighbourhood I got in one little fight and my mom got scared and said you're moving with your auntie and uncle in bel air. aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa wrapped", 0

// GSU code

// vim:ft=snes
