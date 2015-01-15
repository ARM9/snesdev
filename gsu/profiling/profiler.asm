
macro CallGSU(routine) {
    //a8
    //i16
    lda #^routine
    ldx #.loword(routine)
    jsl profile_gsu_program
}


profile_gsu_program:
    //a8
    //i16
    php
    ldy #$0000
    sta GSU_PBR
    lda #(GSU_RON|GSU_RAN)
    sta GSU_SCMR
    lda #$20
    stx GSU_R15 // Go
-
    iny             
    bit GSU_SFR 
    bne -

    stz GSU_SCMR

    plp
    rtl

runTests:
    sei
    stz $4200

    lda nmitimen
    sta $4200
    cli
    rts

// vim:ft=snes
