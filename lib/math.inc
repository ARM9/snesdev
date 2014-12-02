
scope div16: {
//returns:
//  zp0 = quotient
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
