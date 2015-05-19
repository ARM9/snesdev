
if !{defined _PPU_INC} {
define _PPU_INC(1)

include "mem.inc"

macro RGB15(evaluate r, evaluate g, evaluate b) {
    ({b}<<10 | {g}<<5 | {r})
}

    bss()
// stored in contiguous blocks relative to mmio
// {
inidisp_mirror:;    fill 1
obsel_mirror:;      fill 1
//oamadd_mirror:
//oamaddl_mirror:;    fill 1
//oamaddh_mirror:;    fill 1
// }

// {
bgmode_mirror:;     fill 1
mosaic_mirror:;     fill 1
bg1sc_mirror:;      fill 1
bg2sc_mirror:;      fill 1
bg3sc_mirror:;      fill 1
bg4sc_mirror:;      fill 1
bg12nba_mirror:;    fill 1
bg34nba_mirror:;    fill 1
// }

m7sel_mirror:;      fill 1

// {
w12sel_mirror:;     fill 1
w34sel_mirror:;     fill 1
wobjsel_mirror:;    fill 1
wh0_mirror:;        fill 1
wh1_mirror:;        fill 1
wh2_mirror:;        fill 1
wh3_mirror:;        fill 1
wbglog_mirror:;     fill 1
wobjlog_mirror:;    fill 1
tm_mirror:;         fill 1
ts_mirror:;         fill 1
tmw_mirror:;        fill 1
tsw_mirror:;        fill 1
cgwsel_mirror:;     fill 1
cgadsub_mirror:;    fill 1
coldata_mirror:;    fill 1
// }

    bank0()
scope PPU {


updateRegs: {
    php
    rep #$30
    lda.w inidisp_mirror
    sta.w REG_INIDISP
    // REG_OBSEL

    lda.w bgmode_mirror
    sta.w REG_BGMODE
    lda.w bg1sc_mirror
    sta.w REG_BG1SC
    lda.w bg3sc_mirror
    sta.w REG_BG3SC
    lda.w bg12nba_mirror
    sta.w REG_BG12NBA

    lda.w w12sel_mirror
    sta.w REG_W12SEL
    lda.w wobjsel_mirror
    sta.w REG_WOBJSEL
    lda.w wh1_mirror
    sta.w REG_WH1
    lda.w wh3_mirror
    sta.w REG_WH3
    lda.w wobjlog_mirror
    sta.w REG_WOBJLOG
    lda.w ts_mirror
    sta.w REG_TS
    lda.w tsw_mirror
    sta.w REG_TSW
    lda.w cgadsub_mirror
    sta.w REG_CGADSUB

    plp
    rts
}
}

}
// vim:ft=snes
