
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

constant GSU_SRAM_PRG($700000)

GSU_PRGROM:

    push base
    base GSU_SRAM_PRG

scope gsuXorTest: {
// returns:
//  r0 = r1 XOR (r2 XOR (r3 XOR r4))
// args: (initiated by scpu)
//  r1 = u16
//  r2 = u16
//  r3 = u16
//  r4 = u16
    with r3; xor r4
    with r2; xor r3
    from r1; xor r2

    stop; nop
}

scope gsuXoriTest: {
// returns:
//  r0 = r1 XOR #$0B
// args: (initiated by scpu)
//  r1 = u16
    from r1
    to r0
    xor #$0B

    stop; nop
}

    pull base
constant GSU_PRGROM_SIZE(pc() - GSU_PRGROM)
// vim:ft=snes
