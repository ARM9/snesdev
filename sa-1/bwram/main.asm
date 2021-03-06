
macro seek(variable offset) {
    origin ((offset & $7f0000) >> 1) | (offset & $7fff)
    base offset
}

    arch snes.cpu

include "segments.inc"
include "header.inc"
include "../../lib/snes_regs_sa1.inc"
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
include "sa1_init.asm"

include "assets.asm"
//------------------------------------------------
constant WRAM_PRG($7E8000)
//------------------------------------------------

    bss()
nmitimen_mirror:;   fill 1
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

    jsr initSA1

    LoadWram($008000, WRAM_PRG, $8000)

    phk
    plb
    jml $7E0000|wramMain

scope wramMain: {
    sep #$20

    jsr setupVideo
    jsr initSA1
    jsr bootSA1

    jsr Interrupts.init
    //cli
_forever:
    wai

    rep #$30
    lda.l $400100
    itoa(parity_string_bank0)
    lda.w #$000a
    sta.w parity_string_bank0 + 4
    sep #$20
    PrintString(parity_string_bank0, 1, 1)

    rep #$30
    lda.l $410100
    itoa(parity_string_bank1)
    lda.w #$000a
    sta.w parity_string_bank1 + 4
    sep #$20
    PrintString(parity_string_bank1, 1, 2)

    rep #$30
    lda.l $420100
    itoa(parity_string_bank2)
    lda.w #$000a
    sta.w parity_string_bank2 + 4
    sep #$20
    PrintString(parity_string_bank2, 1, 3)

    rep #$30
    lda.l $430100
    itoa(parity_string_bank3)
    lda.w #$000a
    sta.w parity_string_bank3 + 4
    sep #$20
    PrintString(parity_string_bank3, 1, 4)

    jmp _forever
}

scope setupVideo: {
    php
    rep #$10; sep #$20

    LoadVram(torus_sans, $7000, torus_sans.size)
    LoadVram(lake, $0000, lake.size)
    LoadCgram(lake_pal, 0, lake_pal.size)

    lda.b #$00
    sta.w REG_CGADD
    lda.b #$EF
    sta.w REG_CGDATAW
    sta.w REG_CGDATAW

    lda.b #$09
    sta.w bgmode_mirror

    lda.b #$01
    tsb.w tm_mirror

    lda.b #$22|2
    sta.w bg1sc_mirror

    lda.w bg12nba_mirror
    and.b #$F0
    sta.w bg12nba_mirror

    stdout.Init(3, 0, 1)

    lda.b #$0F
    sta.w inidisp_mirror

    plp
    rts
}

//- SA-1 code ------------------------------------
include "sa1/sa1-main.asm"

// vim:ft=snes
