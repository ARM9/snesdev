
    bank0()
scope Interrupts {
init:
    php
    sep #$20
    LoadWram(DummyVectors, $7E00EC, DummyVectors.size)

    lda.b #$81
    sta.w REG_NMITIMEN

    plp
    rts
}

scope nmiHandler: {
    rep #$30
    pha; phx; phy; phb; phd
    
    lda.w #$0000; tcd
    sep #$20
    pha; plb

    lda.w REG_RDNMI

    jsr stdout.dmaWramBufferToVram

    rep #$20
    lda.w bg1_x
    inc
    sta.w bg1_x
    lsr
    sep #$20
    sta.w REG_BG1HOFS
    stz.w REG_BG1HOFS

    lda.w inidisp_mirror
    sta.w REG_INIDISP

    lda.w bgmode_mirror
    sta.w REG_BGMODE

    lda.w bg12nba_mirror
    sta.w REG_BG12NBA
    lda.w bg34nba_mirror
    sta.w REG_BG34NBA

    lda.w tm_mirror
    sta.w REG_TM

    rep #$30
    pld; plb; ply; plx; pla
    rtl
}

scope irqHandler: {
    rep #$30
    pha

    sep #$20
    lda.l REG_TIMEUP // read both nmi and irq flag

    rep #$30
    pla
    rtl
}

constant WRAM_NMI_VECTOR($F2)
constant WRAM_IRQ_VECTOR($F6)

scope DummyVectors: {
    nop //cop
    nop
    nop //brk
    nop
    stp //abort
    nop
    bra + //NMI
    //nop
    nop //unused
    nop
    //IRQ
    jsl $7E0000 | (irqHandler & $FFFF)
    rti
+
    jsl $7E0000 | (nmiHandler & $FFFF)
    rti
constant size(pc() - DummyVectors)
}

// vim:ft=snes
