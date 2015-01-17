
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

constant GSU_SRAM_PRG($700000)

GSU_PRGROM:

    push base
    base GSU_SRAM_PRG


    pull base
constant GSU_PRGROM_SIZE(pc() - GSU_PRGROM)
// vim:ft=snes
