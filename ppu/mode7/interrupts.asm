
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
    inc.b frame_count

    jsr updateCamera

    lda.w inidisp_mirror
    sta.w REG_INIDISP
    lda.w hdmaen_mirror
    sta.w REG_HDMAEN

    rep #$30
    plb; pld; ply; plx; pla
    rti
}

//constant OFFSET_CX(-128)
//constant OFFSET_CY(-112)
constant OFFSET_CX($80)
constant OFFSET_CY($D6)

scope updateCamera: {
    php

    rep #$30
    lda.b frame_count
    eor #-1; inc
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
    eor #-1; inc
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

    rep #$30
    lda.w Camera.x
    inc
    sta.w Camera.x
    sep #$20
    sta.w REG_BG1HOFS
    xba
    sta.w REG_BG1HOFS
    xba
    rep #$21
    adc.w Camera.cx
    sep #$20
    sta.w REG_M7X
    xba
    sta.w REG_M7X

    rep #$21
    lda.w Camera.y
    inc
    sta.w Camera.y
    sep #$20
    sta.w REG_BG1VOFS
    xba
    sta.w REG_BG1VOFS
    xba
    rep #$21
    adc.w Camera.cy
    sec; sbc.w Camera.fov
    sep #$20
    sta.w REG_M7Y
    xba
    sta.w REG_M7Y

    plp
    rts
}

// vim:ft=snes
