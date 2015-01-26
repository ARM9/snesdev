
macro seek(variable offset) {
    origin ((offset & $7f0000) >> 1) | (offset & $7fff)
    base offset
}
if 0 {
    arch snes.cpu

include "segments.inc"
include "header.inc"
include "../../lib/snes_regs.inc"
include "../../lib/zpage.inc"
    bank0()
constant _STACK_TOP($2FF)
include "../../lib/snes_init.inc"

//------------------------------------------------
    bank0()
include "../../lib/mem.inc"
include "../../lib/ppu.inc"
include "../../lib/timing.inc"
include "../../lib/stdio.inc"

//------------------------------------------------
include "interrupts.asm"

include "assets.asm"
//------------------------------------------------
constant WRAM_PRG($7E8000)
//------------------------------------------------

    bank0()
newline_space:; db "\n", 0

    bss()
bg1_x:; fill 2

parity_string_bank0:; fill 4 + 3
parity_string_bank1:; fill 4 + 3
parity_string_bank2:; fill 4 + 3
parity_string_bank3:; fill 4 + 3


//------------------------------------------------
    bank0()

_start:
    InitSnes()

//------------------------------------------------
main:
    rep #$10
    sep #$20

    LoadWram($008000, WRAM_PRG, $8000)

    phk
    plb
    jml $7E0000|WRAM_main

scope WRAM_main: {
    sep #$20

    jsr stdout.init

    jsr setupVideo

    jsr Interrupts.init
    //cli
_forever:
    wai
    jmp _forever
}

scope setupVideo: {
    php

    rep #$10
    sep #$20
    LoadVram(torus_sans, $7000, torus_sans.size)

    lda.b #$00
    sta.w REG_CGADD
    lda.b #$EF
    sta.w REG_CGDATAW
    sta.w REG_CGDATAW

    lda.b #$09
    sta.w REG_BGMODE
    lda.b #$05
    sta.w REG_TM

    lda.b #$22|2
    sta.w REG_BG1SC
    lda.b #$00
    sta.w REG_BG12NBA

    lda.b #((stdout.VRAM_MAP_ADDR >> 8) & $FC)
    sta.w REG_BG3SC
    lda.b #(stdout.VRAM_TILES_ADDR >> 12)&$F
    sta.w REG_BG34NBA

    lda.b #$0F
    WaitForHblank()
    sta.w REG_INIDISP

    plp
    rts
}
//- cx4 code -------------------------------------
include "cx4/main.asm"

}
// vim:ft=snes
