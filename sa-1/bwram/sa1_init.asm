
    bank0()
scope initSA1: {
    php

    sep #$20

    lda.b #SA1_CCNT_STOP
    sta.w SA1_CCNT  // stop SA-1

    stz.w SA1_SIE   // disable scpu IRQ
    stz.w SA1_SIC   // clear scpu IRQ

    stz.w SA1_CXB   // no fancy memory mapping
    stz.w SA1_DXB   // no fancy memory mapping
    stz.w SA1_EXB   // no fancy memory mapping
    stz.w SA1_FXB   // no fancy memory mapping

    lda.b #$80
    sta.w SA1_CDMA  // terminate Character DMA

    stz.w SA1_BMAPS // BWRAM $2000 page to be mapped to $6000-$7FFF
    sta.w SA1_SBWE  // enable writing BWRAM

    lda.b #$FF
    sta.w SA1_SIWP  // enable scpu writing IWRAM
    sta.w SA1_BWPA  // enable scpu writing BWRAM

    stz.w SA1_SDAL  // DMA source address
    stz.w SA1_SDAM
    stz.w SA1_SDAH

    stz.w SA1_DDAL  // DMA destination address
    stz.w SA1_DDAM
    stz.w SA1_DDAH

    rep #$20
    stz.w SA1_DTC   // DMA transfer size in bytes

    lda.w #SA1_start
    sta.w SA1_CRV   // SA-1 reset vector
    
    lda.w #WRAM_NMI_VECTOR
    sta.w SA1_SNV   // scpu nmi vector
    lda.w #WRAM_IRQ_VECTOR
    sta.w SA1_SIV   // scpu irq vector

    plp
    rts
}

scope bootSA1: {
    php

    sep #$20

    stz.w SA1_CCNT  // boot SA-1

    plp
    rts
}

