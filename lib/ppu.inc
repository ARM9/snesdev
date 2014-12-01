
scope dma {
to_cgram:
    //a8
    //i16
    stx.w $4302
    sta.w $4304
    sty.w $4305
    
    ldx.w #$2200
    stx.w $4300

    lda.b #$01
    sta.w $420b
    rts

to_vram:
    //a8
    //i16
    stx.w $4302
    sta.w $4304
    sty.w $4305

    lda.b #$80
    sta.w $2115

    ldx.w #$1801
    stx.w $4300 // DMA mode word write, normal increment, dest $2118

    lda.b #$01
    sta.w $420b
    rts

fixed_to_vram:
    //a8
    //i16
    stx.w $4302
    sta.w $4304
    sty.w $4305

    lda.b #$80
    sta.w $2115

    ldx.w #$1809
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
    jsr dma.to_cgram
}

macro LoadVram(src, dest, size) {
    //a8
    //i16
    ldx.w #{dest}
    stx.w $2116

    ldx.w #{src}
    lda.b #{src}>>16
    ldy.w #{size}
    jsr dma.to_vram
}

macro FillVram(src, dest, size) {
    //a8
    //i16
    ldx.w #{dest}
    stx.w $2116
    ldx.w #{src}
    lda.b #{src}>>16
    ldy.w #{size}
    jsr dma.fixed_to_vram
}

// vim:ft=bass
