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

scope rcp8_lut: {
variable x(1)
while x <= 128 {
    db 0x100/x
    variable x(x+1)
}
}

// vim:ft=snes
