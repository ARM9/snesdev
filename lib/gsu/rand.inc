
    arch snes.gsu

    sram0() // todo: sramzp()
sram_rand_seed1:;  fill 2
sram_rand_seed2:;  fill 2

    bank0()

// quick and dirty prng
scope rand: {
// output:
//  s16 r0  = pseudo-random number
// input: -
// vars:
// clobbers:
//  r0-r2
    // 34 cycles
    lms r0, (sram_rand_seed2)
    lms r1, (sram_rand_seed1)
    move r2, r0 // r2 = sram_rand_seed2
    // __seed1 += (__seed2>>1)
    lsr
    add r1
    sbk
    // __seed2 -= __seed1^0xF 
    xor #$0F
    with r2; sub r0
    sms (sram_rand_seed2), r2
    ret
    nop
}

scope srand: {
// output: void
// input:
    define seed(r0) // u16
// vars:
    define seed_ptr(r1) // u16*
// clobbers:
//  r0, r1
    // __seed2 = r0
    iwt r1, #sram_rand_seed2
    stw (r1)
    // __seed1 <<= 1
    with r1; sub #2
    ldw (r1)
    rol

    ret
    sbk
}

// vim:ft=snes
