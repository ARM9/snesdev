
    bss()
irq_index:;  fill 2

    bank0()
scope Interrupts {

define irq_htiming($00E0)
define topIrq_vtiming($001E)
define endIrq_vtiming($00BE)

setupIrq:
    //a8
    //i16
    ldx.w #$0002
    stx.w irq_index

    ldx.w #{irq_htiming}
    stx.w REG_HTIMEL
    ldx.w #{topIrq_vtiming}
    stx.w REG_VTIMEL

    lda.b #$31
    sta.w REG_NMITIMEN
    cli

    rts

irqRoutinesTable:
dw screenTopIrq
dw screenEndIrq

screenTopIrq:
    sep #$30
    ldx.w inidisp_mirror
    WaitForHblank()
    stx.w REG_INIDISP

    rep #$30
    lda.w #{irq_htiming}
    sta.l REG_HTIMEL
    lda.w #{endIrq_vtiming}
    sta.l REG_VTIMEL

    ldx.w #$0002
    stx.w irq_index

    rts

screenEndIrq:
    sep #$30
    ldx.b #$8F
    WaitForHblank()
    stx.w REG_INIDISP

    rep #$30
    lda.w #{irq_htiming}
    sta.l REG_HTIMEL
    lda.w #{topIrq_vtiming}
    sta.l REG_VTIMEL

    lda.w #$0000
    sta.w irq_index

    sep #$20
    inc.b frame_counter

    jsr chugFramebuffer

    rts

nmiHandler:
    // No nmi, using IRQ for longer Vblank
    stp
irqHandler:
    rep #$30
    pha
    lda.l REG_RDNMI // Read both nmi and irq flag
    bmi + // Check if IRQ was triggered by console
    lda.l GSU_SFR // else clear gsu irq and do nothing in particular
    pla
    rti

+;  sei
    phb; phx; phy

    sep #$20
    lda.b #irqRoutinesTable>>16; pha; plb

    ldx.w irq_index
    jsr (irqRoutinesTable,x)
    
    rep #$30
    ply; plx; plb; pla
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
