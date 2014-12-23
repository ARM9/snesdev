    arch snes.gsu

scope sqrt16: {
// returns:
//  u16 r1  = square root of num
// args:
    define num(r3)  // u16
// vars:
    define res(r1)  // u16
    define bit(r2)  // u16
    define t0(r4)   // u16
// clobbers:
//  r0-r4
    //short res = 0;
    ibt {res}, #0
    //short bit = 1 << 14; // The second-to-top bit is set: 1 << 30 for 32 bits
    iwt {bit}, #1<<14
 
    //while (num < bit)
    with {bit}
-
        //bit >>= 2;
    lsr; with {bit}; lsr

    from {num}; sub {bit}
    blt -
    with {bit} //\

    from {bit} /// moves {bit}, {bit}
    beq _end
    //while (bit != 0) {
    to r4
L0:
    //if (num >= res + bit) {
    from {res}; add {bit}   // r4 = res + bit
    from {num}; sub r4      // r0 = num - r4
    blt +
        //num -= res + bit;
        with {num}; sub r4
        //res = (res >> 1) + bit;
        from {res}; lsr     // r0 = res>>1
        to {res}; add {bit} // res = r0 + bit
        bra ++
        with {bit}
    //}
    //else
+
        //res >>= 1;
        with {res}; lsr
        with {bit}
+
    //bit >>= 2;
    lsr; with {bit}; lsr
    //}
    bne L0
    to r4

    //return res;
_end:
    ret
    nop
}

// vim:ft=bass
