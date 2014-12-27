
    include "snes_regs.inc"

if ((header.MAP_MODE & 1) == 1) {
    constant REG_DSPIO($806000) // HIROM
    constant REG_DSP_DATA($806000)
    constant REG_DSP_STATUS($807000) //Status register
    constant DSP_BANK($80)
} else {
    constant REG_DSPIO($BF8000) // LOROM
    constant REG_DSP_DATA($BF8000)
    constant REG_DSP_STATUS($BFC000)
    constant DSP_BANK($BF)
}

macro scope WaitRQM() {
    //a16
L{#}:
    bit.w REG_DSP_STATUS
    bpl L{#} // bit 15 of DR register set when ready
}

macro scope WaitRQMLong() {
    // clobbers accumulator
    //a16
L{#}:
    lda.l REG_DSP_STATUS
    bpl L{#} 
}

// vim:ft=bass
