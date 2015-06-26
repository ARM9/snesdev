
macro ResetCache() {
    php
    sep #$20
    //lda.b #GSU_SFR_GO
    //sta.w GSU_SFR
    stz.w GSU_SFR // should clear the cache flags and reset CBR to 0x0000
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
    stdout.SetPalette(0)
    sep #$20

    lda.b #1
    sta.w GSU_CLSR  // Set clock frequency to 21.4MHz

    // mult
    puts("\n 21mhz slow mult: ")
    lda.b #(GSU_CFGR_IRQ_MASK)
    sta.w GSU_CFGR
    CallGSU(multTest)

    ResetCache()

    puts("\n 21mhz fast mult: ")
    lda.b #(GSU_CFGR_IRQ_MASK | GSU_CFGR_FASTMUL)
    sta.w GSU_CFGR
    CallGSU(multTest)

    ResetCache()

    //umult
    puts("\n 21mhz slow umult:")
    lda.b #(GSU_CFGR_IRQ_MASK)
    sta.w GSU_CFGR
    CallGSU(umultTest)

    ResetCache()

    puts("\n 21mhz fast umult:")
    lda.b #(GSU_CFGR_IRQ_MASK | GSU_CFGR_FASTMUL)
    sta.w GSU_CFGR
    CallGSU(umultTest)

    ResetCache()

    //fmult
    puts("\n 21mhz slow fmult:")
    lda.b #(GSU_CFGR_IRQ_MASK)
    sta.w GSU_CFGR
    CallGSU(fmultTest)

    ResetCache()

    puts("\n 21mhz fast fmult:")
    lda.b #(GSU_CFGR_IRQ_MASK | GSU_CFGR_FASTMUL)
    sta.w GSU_CFGR
    CallGSU(fmultTest)

    ResetCache()

    //lmult
    puts("\n 21mhz slow lmult:")
    lda.b #(GSU_CFGR_IRQ_MASK)
    sta.w GSU_CFGR
    CallGSU(lmultTest)

    ResetCache()

    puts("\n 21mhz fast lmult:")
    lda.b #(GSU_CFGR_IRQ_MASK | GSU_CFGR_FASTMUL)
    sta.w GSU_CFGR
    CallGSU(lmultTest)

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
    //asl #3
    //dec
    // gsu cycles
    //sta.b zp0
    //asl #2
    //clc
    //adc.b zp0

    itoa(tmp_str)

    sep #$20
    puts(" 0x")
    PrintString(tmp_str)
    puts("\n")
    //puts(" scpu cycles.\n")

    plp
    pld
    rts
}

// vim:ft=snes
