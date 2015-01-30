
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

//------------------------------------------------
    sram0()
transformed_points:;    fill points.size

//------------------------------------------------
    bank0()
//------------------------------------------------

gsuMatrixTest:
    iwt r10, #$400 // stack pointer

    ibt r0, #points>>16
    romb

    cache
.L0:
    iwt r1, #$0010 //m12_11
    iwt r2, #$0000 //m21_13
    iwt r3, #$0010 //m23_22
    iwt r4, #$0000 //m32_31
    iwt r5, #$0010 //m00_33
    iwt r6, #transformed_points
    iwt r12, #(points.size/3)
    iwt r14, #points
    jal mulMat3Vec3
    nop

    stop
    nop
    bra .L0
    nop

include "matrix3.asm"

//------------------------------------------------
scope points: {
//db 1, 2, 3
db $10, $20, $30
constant size(pc() - points)
}

//------------------------------------------------
// vim:ft=snes
