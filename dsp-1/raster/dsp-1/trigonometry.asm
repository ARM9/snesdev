
dspSinCos:
// returns:
//  x16 = sin(angle)
//  y16 = cos(angle)
// args:
//  x16 = angle
//  y16 = radius
    //a8
    //i16
    php

    sep #$20
    lda.b #$04
    sta.w REG_DSP_DATA

    rep #$21
    stx.w REG_DSP_DATA // angle
    // safe to skip RQM check here
    nop; nop; nop
    nop; nop; nop
    nop; nop; nop
    sty.w REG_DSP_DATA // radius
    nop; nop; nop
    nop; nop; nop
    nop; nop; nop
    ldx.w REG_DSP_DATA // radius*sin(angle)
    nop; nop; nop
    nop; nop; nop
    nop; nop; nop
    ldy.w REG_DSP_DATA // radius*cos(angle)

    plp
    rts

dspRotate2D:
// returns:
//  x16 = x2
//  y16 = y2
// args:
//  zp0 = u16 angle
//  x16 = x1
//  y16 = y1
    //a8
    //i16
    php

    sep #$20
    lda.b #$0C
    sta.w REG_DSP_DATA

    rep #$20
    lda.b zp0
    sta.w REG_DSP_DATA
    stx.w REG_DSP_DATA
    sty.w REG_DSP_DATA

    //WaitRQM()
    nop; nop; nop
    nop; nop; nop
    nop; nop; nop

    ldx.w REG_DSP_DATA
    ldy.w REG_DSP_DATA

    plp
    rts

// vim:ft=bass
