
if !{defined _MATH_INC} {
define _MATH_INC(1)

    bss()
__rand_seed1:;  fill 2
__rand_seed2:;  fill 2

    bank0()
scope rand: {
// in: void
// out:
//  a16 = pseudo random number
    //a16
    lda.w __rand_seed2
    lsr
    clc
    adc.w __rand_seed1
    sta.w __rand_seed1
    eor.w #$000F
    sta.b zp0
    lda.w __rand_seed2
    sec
    sbc.b zp0
    sta.w __rand_seed2
    rts
}

scope srand: {
// in:
//  a16 = seed
// out: void
    //a16
    sta.w __rand_seed2
    rol.w __rand_seed1
    rts
}

// unsigned 8*8 multiplication
macro umult8(B) {
// in:
//  a8  = factor A
//  B   = factor B
// out:
//  a16 = product
    //a8
    sta.w REG_WRMPYA
    lda {B}
    sta.w REG_WRMPYB // slow        fast        total
    rep #$20         // 8+8+6       6+6+6       3
    lda.w REG_RDMPYL // 8+8+8+8+8   6+6+6+8+8   8
}

macro umult8(A, B) {
// in:
//  A   = factor A
//  B   = factor B
// out:
//  a16 = product
    //a8
    lda {A}
    sta.w REG_WRMPYA
    lda {B}
    sta.w REG_WRMPYB // slow        fast        total
    rep #$20         // 8+8+6       6+6+6       3
    lda.w REG_RDMPYL // 8+8+8+8+8   6+6+6+8+8   8
}

// unsigned 16/8 division
macro udiv16x8() {
// in:
//  x16 = numerator
//  a8  = denominator
// out:
//  REG_RDDIVL/H = quotient of x16/a8
//  REG_RDMPYL/H = 16 bit remainder
    stx.w REG_WRDIVL
    sta.w REG_WRDIVB // slow        fast        total
    rep #$20         // 8+8+6       6+6+6       3
    nop              // 8+6         6+6         5
    nop              // 8+6         6+6         7
    nop              // 8+6         6+6         9
    nop              // 8+6         6+6         11
  //lda.w REG_RDDIVL // 8+8+8+8+8   6+6+6+8+8   16
}

// signed 16/16 division
scope div16: {
// in:
//  x16 = numerator
//  a16 = denominator
// out:
//  zp0 = quotient of x16/a16
//  x16 = remainder
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

}
// vim:ft=snes
