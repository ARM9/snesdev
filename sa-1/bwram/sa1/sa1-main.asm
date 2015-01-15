
    bank0()

SA1_start:
    sei
    clc
    xce
    rep #$39
    ldx.w #$1FFF
    txs
    
    lda.w #$0000
    tcd
    
    phk
    plb

    lda.w #$4242
    sta.l $400100

    lda.w #$3141
    sta.l $410100

    lda.w #$FEED
    sta.l $420100

    lda.w #$BACC
    sta.l $430100

-
    //wai
    bra -

// vim:ft=snes
