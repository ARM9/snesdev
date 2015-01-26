
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

//------------------------------------------------
    sram0()
fill $400
transformed_points:;    fill points.size

//------------------------------------------------
    bank0()
constant GSU_SRAM_PRG($700000)
GSU_PRGROM:

    push base
    base GSU_SRAM_PRG
//------------------------------------------------

gsuMatrixTest:
    ibt r0, #points>>16
    romb
    iwt r10, #$300 // stack pointer
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
    pull base
scope points: {
//db 1, 2, 3
db $10, $20, $30
constant size(pc() - points)
}

//------------------------------------------------
constant GSU_PRGROM_SIZE(pc() - GSU_PRGROM)
// vim:ft=snes
