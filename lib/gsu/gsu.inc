
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
macro pushr(reg) {
    dec r10; dec r10
    if ({reg} != 0) {
        with r{reg}
    }
    stw (r10)
}

// empty descending would allow popr(r15) sub return
macro popr(reg) {
    if ({reg} != 0) {
        with r{reg}
    }
    ldw (r10)
    inc r10; inc r10
}

macro max(a, b) {
// returns:
//  s16 r0  = the bigger number
// args:
//  s16 a
//  s16 b
// vars:
// clobbers:
//  r0
    // a < b ? b : a;
    from {a}; sub {b}
    blt L0{#};
     with r0
    from {a}
    bra L1{#};
     nop
L0{#}:
    //moves r0, {a}
    from {b}
L1{#}:
}

macro min(a, b) {
// returns:
//  s16 r0  = the smaller number
// args:
//  s16 a
//  s16 b
// vars:
// clobbers:
//  r0
    // a < b ? a : b;
    from {a}; sub {b}
    blt L0{#};
     with r0
    from {b}
    bra L1{#};
     nop
L0{#}:
    //moves r0, {a}
    from {a}
L1{#}:
}

macro BlockSize(start) {
    print "\n{start} block size: "
    print pc() - {start}
    print " bytes\n"
}
// vim:ft=snes
