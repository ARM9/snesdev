
macro ResetCache() {
    php
    sep #$20
    stz.w GSU_SFR // this clears the data in the cache and resets CBR to 0x0000
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
    stz $4200
    
    rep #$30
    stdout.SetXY(0,1)
    stdout.SetPalette(0)
    sep #$20

    puts("\n 21mhz slow mult:\n")
    lda.b #(GSU_CFGR_IRQ_MASK)
    sta.w GSU_CFGR
    CallGSU(multTest)
    
    ResetCache()

    puts("\n 21mhz fast mult:\n")
    lda.b #(GSU_CFGR_IRQ_MASK | GSU_CFGR_FASTMUL)
    sta.w GSU_CFGR
    CallGSU(multTest)

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
    // scpu cycles, slight deviation due to scpu poll loop and not counting master cycles
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

    plp
    pld
    rts
}

// vim:ft=snes
