
    loram()
tmp_intstr:; fill 5

    bank0()

scope sqrtTest: {
// returns: void
// args: void
    php
    rep #$30

    ldx.w #numbers
L0:
    phx
    rep #$20
    lda.b 0,x
    pha
    itoa(tmp_intstr)
    pla
    jsr runSqrtTest
    pha

    sep #$20
    puts("\n sqrt16($")
    PrintString(tmp_intstr)
    puts("): $")

    rep #$30
    pla; itoa(tmp_intstr)
    sep #$20
    PrintString(tmp_intstr)

    plx; inx; inx
    cpx.w #numbers.end
    bne L0

    plp
    rts
scope numbers: {
dw 0
dw 2
dw 3
dw 5
dw 8
dw 9
dw 10
dw $63
dw $64
end:
}
}

scope runSqrtTest: {
// returns:
//  a16 = sqrt(a16)
// args:
//	a16 = argument for sqrt
// clobbers:
// a, x
    php

    rep #$30

    sta.w GSU_R0

    sep #$20
    lda.b #gsuSqrtTest>>16
    ldx.w #gsuSqrtTest

    sta.w GSU_PBR

    lda.b #(GSU_SCMR_RON|GSU_SCMR_RAN)
    sta.w GSU_SCMR

    lda.b #GSU_SFR_GO
    stx.w GSU_R15 // Go
-
    bit.w GSU_SFR 
    bne -

    stz.w GSU_SCMR

    rep #$30

    lda.w GSU_R0

    plp
    rts
}
// vim:ft=snes
