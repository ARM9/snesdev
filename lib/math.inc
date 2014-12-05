
// unsigned 8*8 multiplication
macro umult8(B) {
//returns:
//  a16 = product
//args:
//  a8  = factor A
//  B   = factor B
    //a8
    sta.w REG_WRMPYA
    lda {B}
    sta.w REG_WRMPYB // slow        fast        total
    rep #$20         // 8+8+6       6+6+6       3
    lda.w REG_RDMPYL // 8+8+8+8+8   6+6+6+8+8   8
}

macro umult8(A, B) {
//returns:
//  a16 = product
//args:
//  A   = factor A
//  B   = factor B
    //a8
    lda {A}
    sta.w REG_WRMPYA
    lda {B}
    sta.w REG_WRMPYB // slow        fast        total
    rep #$20         // 8+8+6       6+6+6       3
    lda.w REG_RDMPYL // 8+8+8+8+8   6+6+6+8+8   8
}

// unsigned 16/8 division
macro div16x8() {
//returns:
//  a16 = quotient of x16/a8
//  REG_RDMPYL/H = 16 bit remainder
//args:
//  x16 = numerator
//  a8  = denominator
    stx.w REG_WRDIVL
    sta.w REG_WRDIVB // slow        fast        total
    rep #$20         // 8+8+6       6+6+6       3
    nop              // 8+6         6+6         5
    nop              // 8+6         6+6         7
    nop              // 8+6         6+6         9
    nop              // 8+6         6+6         11
    lda.w REG_RDDIVL // 8+8+8+8+8   6+6+6+8+8   16
}

// signed 16/16 division
scope div16: {
//returns:
//  zp0 = quotient of x16/a16
//  x16 = remainder
//args:
//  x16 = numerator
//  a16 = denominator
define quotient(zp0)

    stz.b {quotient}
    ldy.w #1
_div1:
    asl
    bcs _div2
    iny
    cpy.w #17
    bne _div1
_div2:
    ror
_div4:
    sta.b zp1
    txa
    sec
    sbc.b zp1
    bcc _div3
    tax
_div3:
    rol.b {quotient}
    lda.b zp1
    lsr
    dey
    bne _div4

    rts
}

// vim:ft=bass
