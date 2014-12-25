
//-------------------------------------
    bss()
hdmaen_mirror:; fill 1
//-------------------------------------

macro InitHdma(chan, mode, reg, src) {
    //a8
    //i16
    ldx.w #({reg}<<8) | ({mode} & $FF)
    ldy.w #{src}
    lda.b #{src}>>16
    if (({mode} & HDMA.indirect) == HDMA.indirect) {
        sta.w $43{chan}7
    }
    jsr HDMA.setChannel{chan}
}

//-------------------------------------
    bank0()
scope HDMA {
constant indirect($40)

macro _EnableChannel(channel) {
    lda.b #{channel}
    tsb.w hdmaen_mirror
}

define i(0)
while ({i} <= 7) {
    setChannel{i}:
        stx.w $43{i}0
        sty.w $43{i}2
        sta.w $43{i}4
        _EnableChannel(1 << {i})
        rts

    evaluate i({i} + 1)
}
}

if 0 {

// 16 bit X = $AABB AA = destination register BB = mode , 16 bit Y = $AABB source address high and low bytes,  8 bit A = source bank
setupHDMAChannel0:
// returns: void
// args:
//  a8  = source bank
//  y16 = source address
//  x16 = low byte: destination register, high byte: hdma mode
    //a8
    //i16
    stx.w $4300 // mode
    //  $4311 = destination register
    sty.w $4302 // low byte
    //  $4313 = high byte
    sta.w $4304

    HDMA._EnableChannel($01)
    rts

setupHDMAChannel1:
    stx.w $4310
    sty.w $4312
    sta.w $4314

    HDMA._EnableChannel($02)
    rts

setupHDMAChannel2:
    stx.w $4320
    sty.w $4322
    sta.w $4324

    HDMA._EnableChannel($04)
    rts

setupHDMAChannel3:
    stx.w $4330
    sty.w $4332
    sta.w $4334

    HDMA._EnableChannel($08)
    rts

setupHDMAChannel4:
    stx.w $4340
    sty.w $4342
    sta.w $4344

    HDMA._EnableChannel($10)
    rts

setupHDMAChannel5:
    stx.w $4350
    sty.w $4352
    sta.w $4354

    HDMA._EnableChannel($20)
    rts

setupHDMAChannel6:
    stx.w $4360
    sty.w $4362
    sta.w $4364

    HDMA._EnableChannel($40)
    rts

setupHDMAChannel7:
    stx.w $4370
    sty.w $4372
    sta.w $4374

    HDMA._EnableChannel($80)
    rts
}
// vim:ft=bass
