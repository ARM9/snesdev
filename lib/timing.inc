
macro scope WaitForHblank() {
    //a8
L{#}:
    bit.w REG_HVBJOY
    bvc L{#}
}

macro scope WaitForHblankLong() {
    //a8
L{#}:
    lda.l REG_HVBJOY
    bit.b #$40
    beq L{#}
}

macro scope WaitForVblank() {
    //a8
L{#}:
    bit.w REG_HVBJOY
    bpl L{#}
}

macro scope WaitForVblankLong() {
    //a8
L{#}:
    lda.l REG_HVBJOY
    bpl L{#}
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
