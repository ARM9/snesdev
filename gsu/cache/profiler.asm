
// In addition, when the SCPU writes 0 to the GO flag of the GSU SFR (forced
// stop if the gsu is executing) all of the cache flags are cleared and the
// CBR is set to 0x0000.
macro ResetCache() {
    php
    sep #$20
    stz.w GSU_SFR // should clear the cache (presumably just flags) and reset CBR to 0x0000
    plp
}

macro CallGSU(routine) {
    //a8
    //i16
    lda.b #{routine}>>16
    ldx.w #{routine}
    jsr profileGsuProgram
}

    bank0()
runTests: {
    php
    sei
    sep #$20
    stz.w $4200
    lda.b #$80
    sta.w REG_INIDISP
    
    rep #$30
    stdout.SetXY(0,1)
    stdout.SetPalette(0)
    sep #$20

    // todo perhaps add a switch to change clock/mult speed
    lda.b #0
    sta.w GSU_CLSR  // Set clock frequency to 10mhz

    lda.b #(GSU_CFGR_IRQ_MASK | GSU_CFGR_FASTMUL)
    sta.w GSU_CFGR

    puts("\n 10mhz fast multiplication\n")


    puts("\n no cache:   ")
    CallGSU(multTestNoCache)

    puts("\n cache:      ")
    CallGSU(multTest)

    puts("\n cache line: ")
    CallGSU(multTestNoCache)

    ResetCache()
    puts("\n Cache cleared?")
    puts("\n no cache:   ")
    CallGSU(multTestNoCache)

    lda.w nmitimen_mirror
    sta.w $4200

    plp
    rts
}

    bss()
tmp_str:; fill 5

    bank0()
profileGsuProgram: {
    phd
    php
    sep #$20
    pha
    rep #$30

    lda.w #$3000
    tcd

    ldy.w #$0000
    sep #$20
    pla
    sta.b GSU_PBR
    lda.b #(GSU_SCMR_RON|GSU_SCMR_RAN)
    sta.b GSU_SCMR
    lda.b #$20
    stx.b GSU_R15 // Go
-
    iny             // 2 todo master cycles
    bit.b GSU_SFR   // 3
    bne -           // 3 , - 1 for last branch (not taken)

    stz.b GSU_SCMR
    rep #$30
    tya

    itoa(tmp_str)

    sep #$20
    puts("0x")
    PrintString(tmp_str)
    puts("\n")

    plp
    pld
    rts
}

// vim:ft=snes
