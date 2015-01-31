
// awful
    bss()
    align($10)
scope OAM {

table:
table_lo:;  fill 512
table_hi:;  fill 32

constant table_lo.size(512)
constant table_hi.size(32)
constant table.size(512+32)
}

    bank0()
scope OAM {
init: {
    php
    rep #$10; sep #$20

    jsr OAM.clear

    lda.b #OBSEL.size32_64
    sta.w obsel_mirror

    LoadWram(OAM.rodata.table_lo, OAM.table_lo, OAM.rodata.table_lo.size)
    LoadWram(OAM.rodata.table_hi, OAM.table_hi, OAM.rodata.table_hi.size)

    plp
    rts

clear: {
    php
    rep #$30

    ldx.w #OAM.table_hi.size-2
    lda.w #$0000
-
    sta.w OAM.table_hi,x    // clear sign and size flag
    dex; dex
    bpl -

    sep #$20

    // this might crash on rev1 cpu because of DMA/HDMA timing bug
    FillWram(OAM.HIDE_YO_SPRITES, OAM.table_lo, OAM.table_lo.size)

    //lda.w #$E0E0    //x,y = $0E,$0E
    //ldx.w #$0000
    //txy
//-
    //sta.w OAM.table_lo,x
    //stz.w OAM.table_lo+2,x  //clear attributes
    //inx; inx; inx; inx
    //cpx #OAM.table_lo.size
    //bcc -

    plp
    rts

HIDE_YO_SPRITES:
db $E0
}

// call during vblank
update: {
    php
    rep #$30
    stz.w REG_OAMADD

    sep #$20
    lda.w obsel_mirror
    sta.w REG_OBSEL

    LoadOam(OAM.table, $00, OAM.table.size)

    plp
    rts
}

rotateSprite: {
    php
    rep #$10; sep #$20

    GsuWaitForStop()
    stz.w GSU_SCMR

    LoadVram($702000, $0000, $1000)

    GsuResume()

    plp
    rts
}
}

// Each sprite entry in oam is 4 bytes (+2 bits in the high table), format is:
//	1 xxxx xxxx
//	2 yyyy yyyy
//	3 tttt tttt Note that this could also be considered as 'rrrrcccc' specifying the row and column of the tile in the 16x16 character table.
//	4 hvoo pppN N = selects which tile table to use, p = set palette 0-7, o = priority, h/v flip
// Each byte in the high table contains settings for 4 sprites, ie 2 bits per sprite.
// bit 0 = X sign, bit 1 = Size bit

// don't hardcode your sprites, this is for testing
scope rodata: {
table_lo:
db 32,  32, $00, %00000000
db 130, 42, $00, %00000000
constant table_lo.size(pc() - table_lo)

table_hi:
db %00001000
constant table_hi.size(pc() - table_hi)
}

}
// vim:ft=snes
