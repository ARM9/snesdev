
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
//define a0(r0)
//define a1(r3)
//define a2(r5)
//define a3(r9)
define sp(r10) // a4
define lr(r11)
define pc(r15)

macro AlignCache() {
    while ((pc() & 15) != 15) {
        nop
    }
}

// useful for checking
macro BlockSize(start) {
    print "\n{start} block size: "
    print pc() - {start}
    print " bytes\n"
}
// vim:ft=snes
