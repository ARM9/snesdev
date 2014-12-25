
    bank0()
scope Interrupts: {

init: {
    lda.b #$81
    sta.w nmitimen_mirror
    sta.w REG_NMITIMEN
    rts
}
}

scope irqHandler: {
    stp
}

scope nmiHandler: {
    rep #$30
    pha; phx; phy; phd; phb

    phk
    plb

    sep #$20
    lda.w REG_RDNMI
    
    rep #$20
    lda.b frame_count
    inc
    sta.b frame_count

    jsr updateCamera

    lda.w inidisp_mirror
    sta.w REG_INIDISP
    lda.w hdmaen_mirror
    sta.w REG_HDMAEN

    rep #$30
    plb; pld; ply; plx; pla
    rti
}

constant OFFSET_CX(-128)
constant OFFSET_CY(-112)

scope updateCamera: {
    php

    rep #$30
    lda.b frame_count
    lsr
    sep #$30
    and.b #$7F
    asl
    tax
    rep #$20
    lda.l hdmaMatrixALUT,x
    sta.w wram_matrixA+4//$4332
    lda.l hdmaMatrixCLUT,x
    sta.w wram_matrixB+4//$4342
    rep #$20
    lda.b frame_count
    lsr
    sep #$20
    clc
    adc.b #64
    and.b #$7F
    asl
    tax
    rep #$20
    lda.l hdmaMatrixCLUT,x
    sta.w wram_matrixC+4

    rep #$20
    lda.w Camera.x
    inc
    sta.w Camera.x
    sep #$20
    sta.w REG_M7X
    xba
    sta.w REG_M7X
    xba
    rep #$21
    adc.w #OFFSET_CX
    sep #$20
    sta.w REG_BG1HOFS
    xba
    sta.w REG_BG1HOFS

    rep #$20
    lda.w Camera.y
    inc
    sta.w Camera.y
    sep #$21 // set carry
    sta.w REG_M7Y
    xba
    sta.w REG_M7Y
    xba
    rep #$20
    sbc.w #$0080//raster_center
    clc
    adc.w #OFFSET_CY
    sep #$20
    sta.w REG_BG1VOFS
    xba
    sta.w REG_BG1VOFS

    plp
    rts
}

// vim:ft=bass
