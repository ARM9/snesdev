    
    arch snes.gsu

scope mulMat3Vec3: {
// returns: void
// args:
    define m12_11(r1) // \ s8 2 matrix components packed in 1 reg
    define m21_13(r2) // |
    define m23_22(r3) // |
    define m32_31(r4) // |
    define m00_33(r5) // /
    define vec3_out(r6) // vec3_s8* data in ram
    define count(r12)   // u16 number of vectors to multiply
    define vec3_in(r14) // vec3_s8* vectors in rom
// vars:
    define x1(r7)
    define y1(r8)
    define z1(r9)
    define tmp(r11)

// clobbers:
//  r0-r9,r11-r14

    // [m11 m12 m13]   [x1]   [m11*x1+m12*y1+m13*z1]
    // [m21 m22 m23] * [y1] = [m21*x1+m22*y1+m23*z1]
    // [m31 m32 m33]   [z1]   [m31*x1+m32*y1+m33*z1]
    pushr(11)
    move r13, r15
L0:
    to {x1}; getb       // x1 = vec3_in[0]
    inc {vec3_in}
    from {m12_11}
    to {tmp}
    mult {x1}           // tmp = m11 * x1

    to {y1}; getb       // y1 = vec3_in[1]
    inc {vec3_in}

    from {m12_11}
    hib
    mult {y1}           // r0 = m12 * y1

    with {tmp}
    add r0              // tmp += r0

    to {z1}; getb       // z1 = vec3_in[2]
    inc {vec3_in}

    from {m21_13}
    mult {z1}           // r0 = m13 * z1
    add {tmp}           // r0 += tmp
    add r0              // r0 *= 2
    hib
    stb ({vec3_out})    // store x1
    inc {vec3_out}

    from {m21_13}
    hib
    to {tmp}
    mult {x1}           // tmp = m21 * x1

    from {m23_22}
    mult {y1}           // r0 = m22 * y1
    with {tmp}
    add r0              // tmp += r0

    from {m23_22}
    hib
    mult {z1}           // r0 = m23 * z1
    add {tmp}           // r0 += tmp
    add r0              // r0 *= 2
    hib
    stb ({vec3_out})    // store y1
    inc {vec3_out}

    from {m32_31}
    to {tmp}
    mult {x1}           // tmp = m31 * x1
    
    from {m32_31}
    hib
    mult {y1}           // r0 = m32 * y1
    with {tmp}
    add r0              // tmp += r0

    from {m00_33}
    mult {z1}           // r0 = m33 * z1
    add {tmp}           // r0 += tmp
    add r0              // r0 *= 2
    hib
    stb ({vec3_out})    // store z1

    loop
    inc {vec3_out}
    
    //popr(15)
    popr(11); ret
    nop
}

scope mulMat3: {
// returns:
// args:
    define m12_11(r1)
    define m21_13(r2)
    define m23_22(r3)
    define m32_31(r4)
    define m00_33(r5)

    define n12_11(r6)
    define n21_13(r7)
    define n23_22(r8)
    define n32_31(r9)
    define n00_33(r11)
    define mat3_out(r12)
// vars:
// clobbers:
//  r0-r9
    // [m11 m12 m13]   [n11 n12 n13]   [     ]
    // [m21 m22 m23] * [n21 n22 n23] = [ ugh ]
    // [m31 m32 m33]   [n31 n32 n33]   [     ]

    ret
}

// vim:ft=snes
