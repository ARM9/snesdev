
    loram()
tmp_intstr:; fill 5

    bank0()
scope sqrtTest: {
define num0($64)
    php

    // store parameters
    rep #$30
    lda.w #{num0}
    sta.w GSU_R0

    sep #$20
    lda.b #gsuSqrtTest>>16
    ldx.w #gsuSqrtTest

    sta.w GSU_PBR

    lda.b #(GSU_SCMR_RON|GSU_SCMR_RAN)
    sta.w GSU_SCMR

    lda.b #GSU_SFR_GO
    ldy.w #$0000
    stx.w GSU_R15 // Go
-
    iny             
    bit.w GSU_SFR 
    bne -

    stz.w GSU_SCMR

    rep #$30

    lda.w GSU_R0
    itoa(tmp_intstr)

    sep #$20
    puts("\n sqrt16({num0}): ")
    PrintString(tmp_intstr)

    plp
    rts
}

// vim:ft=bass
