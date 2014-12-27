
    loram()
tmp_intstr:; fill 5

    bank0()
scope xorTest: {
define r1($101)
define r2($110)
define r3($100)
define r4($8003)
define result($8112)
    php

    // store parameters
    rep #$30
    SetPalette()
    lda.w #{r1}
    sta.w GSU_R1
    lda.w #{r2}
    sta.w GSU_R2
    lda.w #{r3}
    sta.w GSU_R3
    lda.w #{r4}
    sta.w GSU_R4

    sep #$20
    lda.b #gsuXorTest>>16
    ldx.w #gsuXorTest

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
    sta.b zp0
    itoa(tmp_intstr)

    sep #$20
    puts("\n xor\n {r4}^{r3}^{r2}^{r1}: ")
    PrintString(tmp_intstr)

    rep #$30
    lda.b zp0
    cmp.w #{result}
    bne _fail
        SetPalette(2)
        puts("\n ")
    bra +
_fail:
    
+
    plp
    rts
}

scope xoriTest: {
define r1($64)
define result($6F)
    php

    // store parameters
    rep #$30
    lda.w #{r1}
    sta.w GSU_R1

    sep #$20
    lda.b #gsuXoriTest>>16
    ldx.w #gsuXoriTest

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
    sta.b zp0
    itoa(tmp_intstr)

    sep #$20
    puts("\n\n xori\n {r1}^$000B: ")
    PrintString(tmp_intstr)

    plp
    rts
}

// vim:ft=bass
