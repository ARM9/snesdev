
scope Interrupts {
init: {
    //a8
    lda.b #$81
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

    lda.w inidisp_mirror
    sta.w REG_INIDISP

    jsr stdout.dmaWramBufferToVram

    rep #$30
    pld; plb; ply; plx; pla
    rti
}

scope irqHandler: {
    stp
    rti
}

// vim:ft=snes
