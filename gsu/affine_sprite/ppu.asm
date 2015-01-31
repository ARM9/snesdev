
scope Ppu {
updateRegs: {
    php
    sep #$20

    lda.w inidisp_mirror
    sta.w REG_INIDISP

    lda.w obsel_mirror
    sta.w REG_OBSEL

    lda.w bg1sc_mirror
    sta.w REG_BG1SC

    lda.w tm_mirror
    sta.w REG_TM

    plp
    rts
}
}

// vim:ft=snes
