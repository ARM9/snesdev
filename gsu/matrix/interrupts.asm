
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

    rep #$20
    lda.w bg1sc_mirror
    sta.w REG_BG1SC // REG_BG2SC
    lda.w bg3sc_mirror
    sta.w REG_BG3SC // REG_BG4SC

    lda.w bg12nba_mirror
    sta.w REG_BG12NBA
    //lda.w bg34nba_mirror
    //sta.w REG_BG34NBA
    sep #$20

    lda.w tm_mirror
    sta.w REG_TM

    jsr stdout.dmaWramBufferToVram

    rep #$30
    pld; plb; ply; plx; pla
    rti
}

scope irqHandler: {
    rep #$30
    stdout.SetXY(1,1)
    sep #$20
    puts("irqHandler reached wtf??")
    stp
    rti
}

// vim:ft=snes
