
macro GsuWaitForStop() {
    //a8
    lda.b #GSU_SFR_GO
L{#}:
    bit.w GSU_SFR   // Wait for GSU to stop
    bne L{#}
}

macro GsuResume() {
    //a8
    lda.w gsu_scmr_mirror
    sta.w GSU_SCMR
    lda.w GSU_SFR
    ora.b #GSU_SFR_GO
    sta.w GSU_SFR
}

    bss()
irq_index:;  fill 2

    bank0()
scope Interrupts {

init:
    //a8
    //i16
    lda.b #$81
    sta.w nmitimen_mirror
    sta.w REG_NMITIMEN

    rts

nmiHandler:
    // No nmi, using IRQ for longer Vblank
    rep #$30
    pha; phx; phy; phd; phb

    lda.w #$0000; tcd
    sep #$20
    pha; plb

    lda.w REG_RDNMI

    inc.w frame_counter

    jsr PPU.updateRegs
    jsr OAM.update
    jsr OAM.rotateSprite

    rep #$30
    plb; pld; ply; plx; pla
    rti

irqHandler:
    rep #$30
    pha
    lda.l GSU_SFR

    pla
    rti
}

    bank0()
// Interrupt vectors to be executed during 65816 operation in WRAM
// copy to $7E0100
scope dummy_vectors: {
    nop // 0100 brk, abort
    nop
    nop // padding
    rti
    nop // 0104 cop
    nop
    nop // padding
    rti
    // 0108 NMI
    jml $7E0000 | (Interrupts.nmiHandler & $FFFF)
    // 010C IRQ
    jml $7E0000 | (Interrupts.irqHandler & $FFFF)
constant size(pc() - dummy_vectors)
}



// vim:ft=snes
