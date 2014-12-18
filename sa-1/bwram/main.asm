
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

    jsr initSA1

    LoadWram($008000, WRAM_PRG, $8000)
    LoadWram(egg, $403000, egg.size)

    phk
    plb
    jml $7E0000|WRAM_main

scope WRAM_main: {
    sep #$20

    jsr stdout.init

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

    rep #$10
    sep #$20
    LoadVram(torus_sans, $7000, torus_sans.size)
    LoadVram(lake, $0000, lake.size)
    LoadCgram(lake_pal, 0, lake_pal.size)

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

scope initSA1: {
    php

    sep #$20

    lda.b #SA1_CCNT_STOP
    sta.w SA1_CCNT  // stop SA-1

    stz.w SA1_SIE   // disable scpu IRQ
    stz.w SA1_SIC   // clear scpu IRQ

    stz.w SA1_CXB   // no fancy memory mapping
    stz.w SA1_DXB   // no fancy memory mapping
    stz.w SA1_EXB   // no fancy memory mapping
    stz.w SA1_FXB   // no fancy memory mapping

    lda.b #$80
    sta.w SA1_CDMA  // terminate Character DMA

    stz.w SA1_BMAPS // BWRAM $2000 page to be mapped to $6000-$7FFF
    sta.w SA1_SBWE  // enable writing BWRAM

    lda.b #$FF
    sta.w SA1_SIWP  // enable scpu writing IWRAM
    sta.w SA1_BWPA  // enable scpu writing BWRAM

    stz.w SA1_SDAL  // DMA source address
    stz.w SA1_SDAM
    stz.w SA1_SDAH

    stz.w SA1_DDAL  // DMA destination address
    stz.w SA1_DDAM
    stz.w SA1_DDAH

    rep #$20
    stz.w SA1_DTC   // DMA transfer size in bytes

    lda.w #SA1_start
    sta.w SA1_CRV   // SA-1 reset vector
    
    lda.w #WRAM_NMI_VECTOR
    sta.w SA1_SNV   // scpu nmi vector
    lda.w #WRAM_IRQ_VECTOR
    sta.w SA1_SIV   // scpu irq vector

    plp
    rts
}

scope bootSA1: {
    php

    sep #$20

    stz.w SA1_CCNT  // boot SA-1

    plp
    rts
}

//- SA-1 code ------------------------------------
include "sa1/sa1-main.asm"

// vim:ft=bass
