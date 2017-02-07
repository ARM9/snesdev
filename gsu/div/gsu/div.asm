    arch snes.gsu

// signed 16-bit integer division with remainder
scope div: {
// in:
//  s16 r0 = numerator
//  s16 r1 = denominator
// out:
//  s16 r2 = quotient of r0/r1
//  s16 r3 = remainder of r0/r1

    moves r1, r1
    bne +
     ibt r2, #-1
    // division by zero, -1 quot garbage rem
    ret
     nop
+;  db -1

    to r3; xor r1
    bmi one_negative // one operand is negative
     nop
    moves r4, r0
    bpl both_positive
     nop
    // both negative
    not; inc r0
    with r1; not; inc r1
both_positive:
-
    sub r1
    bge -
     inc r2
    // remainder
    to r3; from r0; add r1

    bra fix_rem
    nop

one_negative:
    // negate the one that is negative
    moves r4, r0
    bmi num_negative
     nop
    // denom negative
    with r1
    not
    bra +
     inc r1
num_negative:
    not
    inc r0
+
-
    sub r1
    bge -
     inc r2

    // num or denom is negative make quot negative
    with r2; not; inc r2

    // remainder
    to r3; from r0; add r1

    // if numerator is negative, remainder is negative
fix_rem:
    moves r4, r4
    bpl +
     with r3; not; inc r3
+
    ret
    nop
}

print "div size: "
print pc()-div
print " bytes\n"

// s8.8/u8
scope div16x8: {
// in:
//  s16 numerator
define num(r6)
//  u8 denominator
define den(r1)
// out:
//  s16 r0 = r6/r1

    //ibt r0, #rcp_lut>>16
    //romb

    // den *= 2 for indexing into lut
    with {den}; add {den}
    iwt r0, #rcp_lut
    to r14; add {den}   // r14 = rcp_lut + denominator
    getb
    inc r14
    getbh

    // use lmult to debug low word
    //lmult // r0:r4 = r0 * r6  r0=hi16 r4=lo16
    fmult   // r0 = r0 * r6 >> 16, carry = msb of low 16 bits of result

    // precision is off by one bit for x/1

    // 'rounds' fraction down
    //adc r0

    // 'rounds' fraction up (more like a bias towards higher values since it
    // doesn't always round the fraction up, ex 0x2103/52 = 0x00a2 for both)
    adc #0
    add r0

    ret
     nop
}

// TODO move to sram for faster reads
scope rcp_lut: {
dw 0    // filler word to fix indexing otherwise 1/1 gets the value for 1/2 etc.
constant precision((1<<15) - 1)
variable i(1)
while i <= 255 {
    dw precision / i
    //print precision / i
    //print "\n"
    variable i(i+1)
}
}

// vim:ft=snes
