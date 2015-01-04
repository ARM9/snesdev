
    bank0()

scope Interrupts: {

init: {
    //a8
    //i16
    lda #$81
    sta.w REG_NMITIMEN
    sta.w nmitimen_mirror

    rts
}

}
scope nmiHandler: {
    rep #$30
    pha; phx; phy; phd; phb

    lda.w #$0000
    tcd
    sep #$20
    pha; plb

    inc.b frame_counter

    lda.w REG_RDNMI

    jsr Camera.writePpu

    lda.w inidisp_mirror
    sta.w REG_INIDISP
    lda.w hdmaen_mirror
    sta.w REG_HDMAEN

    jsr Joypad.updatePads

    rep #$30
    plb; pld; ply; plx; pla
    rti
}

scope irqHandler: {
    stp
}

// vim:ft=bass
