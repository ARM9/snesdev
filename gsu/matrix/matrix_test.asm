
    loram()
tmp_intstr:; fill 5

    bank0()
scope matrixTest: {
define r1($00)
define r2($00)
define r3($00)
define r4($00)
define r5($00)
    php
    rep #$30
    stdout.SetPalette(0)

    //lda.w #{r1}
    //sta.w GSU_R1
    //lda.w #{r2}
    //sta.w GSU_R2
    //lda.w #{r3}
    //sta.w GSU_R3
    //lda.w #{r4}
    //sta.w GSU_R4

    sep #$20
    lda.b #gsuMatrixTest>>16
    sta.w GSU_PBR
    ldx.w #gsuMatrixTest

    lda.b #(GSU_SCMR_RON|GSU_SCMR_RAN)
    sta.w GSU_SCMR

    lda.b #GSU_SFR_GO
    stx.w GSU_R15
-
    bit.w GSU_SFR
    bne -

    stz.w GSU_SCMR

    rep #$10
    sep #$20
    puts("\n matrix3_s8 * vec3_s8")

    ldx.w #$0000
-
    sep #$20
    phx
    lda.l transformed_points,x
    rep #$20
    and.w #$00FF
    itoa(tmp_intstr)
    sep #$20
    puts("\n ")
    PrintString(tmp_intstr)
    plx
    inx
    cpx.w #points.size
    bne -

    //rep #$30
    //cmp.w #{result}
    //bne _fail
        //stdout.SetPalette(1)
        //sep #$20
        //puts("\n test passed")
    //bra +
//_fail:
    //stdout.SetPalette(2)
    //sep #$20
    //puts("\n test failed")
//+
    plp
    rts
}


// vim:ft=snes
