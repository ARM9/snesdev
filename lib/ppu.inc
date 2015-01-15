
scope DMA {
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
    sta.w $420B
    rts
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

macro RGB15(evaluate r, evaluate g, evaluate b) {
    ({b}<<10 | {g}<<5 | {r})
}

// vim:ft=snes
