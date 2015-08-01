
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

constant GSU_SRAM_PRG($700000)

GSU_PRGROM:

    push base
    base GSU_SRAM_PRG

scope gsuSqrtTest: {
// output:
//  r0 = square root of x
// input: (initiated by scpu)
//  r0 = x
    move r3, r0
    jal sqrt16
    nop

    move r0, r1
    stop
    nop
}

include "sqrt.asm"

    pull base
constant GSU_PRGROM_SIZE(pc() - GSU_PRGROM)
// vim:ft=snes
