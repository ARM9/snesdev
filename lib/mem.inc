
scope DMA {
constant b_to_a($80)
constant fixed($08)

romToWram:
    //a8
    //i16
    stx.w $4302
    sta.w $4304
    sty.w $4305

    ldx.w #$8000    // wram, 1 register 1 byte
    stx.w $4300

    lda.b #$01
    sta.w $420B
    rts

romFixedToWram:
    //a8
    //i16
    stx.w $4302
    sta.w $4304
    sty.w $4305

    ldx.w #$8008 // $2180, write 1 register once fixed source
    stx.w $4300

    lda.b #$01
    sta.w $420B
    rts

wramToSram:
    //a8
    //i16
    stx.w $4302
    sta.w $4304
    sty.w $4305

    lda.b #$80  // wram
    xba         // mode byte passed in upper byte of accumulator
    tax
    stx.w $4300

    lda.b #$01
    sta.w $420B
    rts
}

macro BlockMoveP(src, dest, size) {
    //a16
    //i16
    ldx.w #{src}
    ldy.w #{dest}
    lda.w #{size}-1
    mvp ({dest}>>16)=({src}>>16)
}

macro BlockMoveN(src, dest, size) {
    //a16
    //i16
    ldx.w #{src}
    ldy.w #{dest}
    lda.w #{size}-1
    mvn ({dest}>>16)=({src}>>16)
}

macro LoadWram(src, dest, size) {
    //a8
    //i16
    ldx.w #{dest}
    stx.w $2181
    lda.b #{dest}>>16
    sta.w $2183

    ldx.w #{src}
    lda.b #{src}>>16
    ldy.w #{size}
    jsr DMA.romToWram
}

macro FillWram(src, dest, size) {
    //a8
    //i16
    ldx.w #{dest}
    stx.w $2181
    lda.b #{dest}>>16
    sta.w $2183
    
    ldx.w #{src}
    lda.b #{src}>>16
    ldy.w #{size}
    jsr DMA.romFixedToWram
}

macro LoadWramSram(src, dest, size, mode) {
    //a8
    //i16
    ldx.w #{src}
    stx.w $2181
    lda.b #{src}>>16
    sta.w $2183

    lda.b #{mode} // direction for transfer
    xba
    ldx.w #{dest}
    lda.b #{dest}>>16
    ldy.w #{size}
    jsr DMA.wramToSram
}

// vim:ft=snes
