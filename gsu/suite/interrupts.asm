
scope Interrupts {
init: {
    //a8
    lda.b #NMITIMEN.nmi | NMITIMEN.autojoy
    sta.w nmitimen_mirror
    sta.w REG_NMITIMEN
    cli
    rts
}

}

scope nmiHandler: {
    rep #$30
    pha; phx; phy; phb; phd
    
    lda.w #$0000
    tcd
    sep #$20
    pha; plb //set known dbr

    lda.w REG_RDNMI
    
    inc.b frame_counter

    jsr PPU.updateRegs

    jsr stdout.dmaWramBufferToVram
    jsr stdout.clearWramBuffer

    jsr Joypad.updatePads

    rep #$30
    pld; plb; ply; plx; pla
    rti
}

scope irqHandler: {
    stp
    rti
}

scope emptyHandler: {
    rti
}

// vim:ft=snes
