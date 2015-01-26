
if !{defined _DMA_INC} {
define _DMA_INC(1)

include "snes_regs.inc"

    bank0()
scope DMA {
constant b_to_a($80)
constant fixed($08)

toOam:
    //a8
    //i16
    stx.w $4302
    sta.w $4304
    sty.w $4305

    ldx.w #$0400
    stx.w $4300

    lda.b #$01
    sta.w $420b
    rts

toCgram:
    //a8
    //i16
    stx.w $4302
    sta.w $4304
    sty.w $4305
    
    ldx.w #$2200 // $2122, write 1 register once
    stx.w $4300

    lda.b #$01
    sta.w $420b
    rts

toVram:
    //a8
    //i16
    stx.w $4302
    sta.w $4304
    sty.w $4305

    lda.b #$80
    sta.w $2115

    ldx.w #$1801 // $2118, write 2 registers once
    stx.w $4300

    lda.b #$01
    sta.w $420b
    rts

toLowVram:
    //a8
    //i16
    stx.w $4302
    sta.w $4304
    sty.w $4305

    stz.w $2115

    ldx.w #$1800 // $2118, write 1 register once
    stx.w $4300

    lda.b #$01
    sta.w $420b
    rts

toHighVram:
    //a8
    //i16
    stx.w $4302
    sta.w $4304
    sty.w $4305

    lda.b #$80
    sta.w $2115

    ldx.w #$1900 // $2118, write 1 register once
    stx.w $4300

    lda.b #$01
    sta.w $420b
    rts

fixedToVram:
    //a8
    //i16
    stx.w $4302
    sta.w $4304
    sty.w $4305

    lda.b #$80
    sta.w $2115

    ldx.w #$1809 // $2118, write 2 registers once fixed source addr
    stx.w $4300

    lda.b #$01
    sta.w $420b
    rts

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

    lda.b #$80
    xba         // mode byte passed in upper byte of accumulator
    tax
    stx.w $4300

    lda.b #$01
    sta.w $420B
    rts
}

macro LoadOam(src, dest, size) {
    //a8
    //i16
    lda.b #{dest}
    sta.w REG_OAMADDL

    ldx.w #{src}
    lda.b #{src}>>16
    ldy.w #{size}
    jsr DMA.toOam
}

macro LoadCgram(src, dest, size) {
    //a8
    //i16
    lda.b #{dest}
    sta.w $2121
    
    ldx.w #{src}
    lda.b #{src}>>16
    ldy.w #{size}
    jsr DMA.toCgram
}

macro LoadVram(src, dest, size) {
    //a8
    //i16
    ldx.w #{dest}
    stx.w $2116

    ldx.w #{src}
    lda.b #{src}>>16
    ldy.w #{size}
    jsr DMA.toVram
}

macro LoadLoVram(src, dest, size) {
    //a8
    //i16
    ldx.w #{dest}
    stx.w $2116

    ldx.w #{src}
    lda.b #{src}>>16
    ldy.w #{size}
    jsr DMA.toLowVram
}

macro LoadHiVram(src, dest, size) {
    //a8
    //i16
    ldx.w #{dest}
    stx.w $2116

    ldx.w #{src}
    lda.b #{src}>>16
    ldy.w #{size}
    jsr DMA.toHighVram
}

macro FillVram(src, dest, size) {
    //a8
    //i16
    ldx.w #{dest}
    stx.w $2116

    ldx.w #{src}
    lda.b #{src}>>16
    ldy.w #{size}
    jsr DMA.fixedToVram
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

}
// vim:ft=snes
