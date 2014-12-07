
macro scope WaitForHblank() {
    //a8
L0{#}:
    bit.w REG_HVBJOY
    bvc L0{#}
}

macro scope WaitForHblankLong() {
    //a8
L0{#}:
    lda.l REG_HVBJOY
    bit.b #$40
    beq L0{#}
}

macro scope WaitForVblank() {
    //a8
L0{#}:
    bit.w REG_HVBJOY
    bpl L0{#}
}

macro scope WaitForVblankLong() {
    //a8
L0{#}:
    lda.l REG_HVBJOY
    bpl L0{#}
}

// Wait for vblank, less code than WaitForScanline(224) and works for interlace
macro scope Vsync() {
    //a8
L0{#}:
    bit.w REG_HVBJOY
    bmi L0{#}
    WaitForVblank()
}

macro scope WaitForScanline(line) {
    //a8
L{#}:
    lda.w $2137
    lda.w $213D
    xba
    lda.w $213D
    and.b #1
    xba
    rep #$20
    cmp.w #{line}
    sep #$20
    bne L{#}
}

// vim:ft=bass
