
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

    bss()
gsu_clsr_mirror:; fill 1
gsu_cfgr_mirror:; fill 1

    bank0()
initMenu: {
    php
    sep #$20
    lda.b #(GSU_CFGR_IRQ_MASK)
    sta.w gsu_cfgr_mirror       // todo bass data sections

    plp
    rts
}

runMenu: {
    php

    rep #$30
    Joypad.Pressed(1)
    bit.w #PAD_DOWN
    beq +
        pha; php
        sep #$20
        lda.w gsu_cfgr_mirror
        eor.b #GSU_CFGR_FASTMUL
        sta.w gsu_cfgr_mirror
        plp; pla
+
    sep #$20

    jsr runTests

    wai

    plp
    rts
}

runTests: {
    php
    sei
    sep #$20
    stz.w REG_NMITIMEN
    //lda.b #INIDISP_FBLANK
    //sta.w REG_INIDISP
    
    rep #$30
    stdout.SetXY(0,1)
    stdout.SetPalette(0)
    sep #$20

    lda.w gsu_clsr_mirror
    sta.w GSU_CLSR  // Set clock frequency
    and.b #GSU_CLSR_21MHZ
    bne +
    puts("\n 10mhz ")
    bra ++
+
    puts("\n 21mhz ")
+

    lda.w gsu_cfgr_mirror
    sta.w GSU_CFGR  // Set multiplication speed
    and.b #GSU_CFGR_FASTMUL
    bne +
    puts("slow mult\n")
    bra ++
+
    puts("fast mult\n")
+

    puts("\n no cache:   ")
    CallGSU(cacheTest1NoCache)

    // fill a cache line
    puts("\n cache:      ")
    CallGSU(cacheTest1)

    puts("\n cache line: ")
    CallGSU(cacheTest1NoCache)

    ResetCache()
    puts("\n Cache cleared?")
    puts("\n no cache:   ")
    CallGSU(cacheTest1NoCache)

    lda.w nmitimen_mirror
    sta.w REG_NMITIMEN

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
