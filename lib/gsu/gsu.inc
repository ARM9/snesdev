
//define r0      $00 ; General purpose, default source/dest register
//define r1      $01 ; Pixel plot X pos register
//define r2      $02 ; Pixel plot Y pos register
//define r3      $03 ; General purpose
//define r4      $04 ; Lower 16 bit result of lmult
//define r5      $05 ; General purpose
//define r6      $06 ; Multiplier for fmult and lmult
//define r7      $07 ; Fixed point texel X position for merge
//define r8      $08 ; Fixed point texel Y position for merge
//define r9      $09 ; General purpose
//define r10     $0A ; General purpose (conventionally stack pointer)
//define r11     $0B ; Return addres set by link
//define r12     $0C ; Loop counter
//define r13     $0D ; Loop point address
//define r14     $0E ; ROM buffer address (writing may cause stall)
//define r15     $0F ; Program counter
define sp(r10)
define lr(r11)
define pc(r15)

macro AlignCache() {
    while ((pc() & 15) != 15) {
        nop
    }
}

// full descending stack
macro push(reg) {
    dec r10; dec r10
    if ({reg} != 0) {
        with r{reg}
    }
    stw (r10)
}

// empty descending would allow popr(r15) sub return
macro pop(reg) {
    if ({reg} != 0) {
        with r{reg}
    }
    ldw (r10)
    inc r10; inc r10
}

// still same size as their word counterpart due to alt byte for stb/ldb
// popb is 1 cycle faster in cache than pop word, and stb is potentially 1
// cycle faster in cache
// otherwise ldb/stb are slower but push word also has +3 cycles from an extra
// dec/inc so pushb/popb are still a little faster
macro pushb(reg) {
    dec r10
    if ({reg} != 0) {
        with r{reg}
    }
    stb (r10)
}
macro popb(reg) {
    if ({reg} != 0) {
        with r{reg}
    }
    ldb (r10)
    inc r10
}

// pass r0 as a, max(0,1) better than max(1,0) cba to make a conditional
macro max(a, b) {
// out:
//  r0      = the bigger number
//  flags   = updates O S Z see MOVES
// in:
//  s16 a
//  s16 b
// vars:
// clobbers:
//  r0

    // a < b ? b : a;

    if {a} != 0 {
        from r{a};
    }
    sub r{b}
    blt L0{#};
     with r0
    //moves r0, {a}
    bra L1{#};
     from r{a}
L0{#}:
    //moves r0, {b}
    from r{b}
L1{#}:
}

macro min(a, b) {
// out:
//  r0      = the smaller number
//  flags   = updates O S Z see MOVES
// in:
//  s16 a
//  s16 b
// vars:
// clobbers:
//  r0

    // a < b ? a : b;

    if {a} != 0 {
        from r{a}
    }
    sub r{b}
    blt L0{#};
     with r0
    //moves r0, {b}
    bra L1{#};
     from r{b}
L0{#}:
    //moves r0, {a}
    from r{a}
L1{#}:
}

macro log2(n) {
// otuput:
//  u16 r2 = log2(n) (p in n = pow(2,p))
// input:
//  u16 n
// clobbers:
//  r0, r2, r3

    ibt r2, #0      // p
    moves r0, {n}   // if n == 0 then return 0
    beq done{#}
     nop
    //if n >= 1<<8
    // p +=8
    // n >>= 8
    iwt r3, #1<<8
    cmp r3
    blt L0{#}
     with r2
      add #8
      hib
L0{#}:
    //if n >= 1<<4
    // p +=4
    // n >>= 4
    ibt r3, #1<<4
    cmp r3
    blt L1{#}
     to r3
      with r2
      add #4
      lsr; lsr; lsr; lsr
      to r3
L1{#}:
    //if n >= 1<<2
    // p +=2
    // n >>= 2
    sub #1<<2
    blt L2{#}
     nop
      inc r2; inc r2
      lsr; lsr
L2{#}:
    //if n >= 1<<1
    // p +=1
    sub #1<<1   // r0 = n - r3
    with r2
    adc #0
done{#}:
}

macro BlockSize(start) {
    print "\n{start} block size: "
    print pc() - {start}
    print " bytes\n"
}
// vim:ft=snes
