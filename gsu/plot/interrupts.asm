
    bss()
irq_index:;  fill 2

    bank0()
scope Interrupts {

define irq_htiming($00E0)
define topIrq_vtiming($000E)
define endIrq_vtiming($00CE)

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
    rtl

+;  sei
    phb; phx; phy

    sep #$20
    lda.b #irqRoutinesTable>>16; pha; plb

    ldx.w irq_index
    jsr (irqRoutinesTable,x)
    
    rep #$30
    ply; plx; plb; pla
    rtl
}

    bank0()
//Interrupt vectors to be executed during 65816 operation in WRAM
scope dummy_vectors: {
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
    jsl $7E0000 | (Interrupts.irqHandler & $FFFF)
    rti
+;  jsl $7E0000 | (Interrupts.nmiHandler & $FFFF)
    rti
constant size(pc() - dummy_vectors)
}

// vim:ft=snes
