
nmiHandler: {
    rep #$30
    pha; phx; phy; phb; phd
    lda.w #$0000
    tcd

    sep #$20
    pha; plb

    lda.w REG_RDNMI

    rep #$30
    pld; plb; ply; plx; pla
    rti
}

irqHandler: {
    stp
    rti
}
// vim:ft=bass
