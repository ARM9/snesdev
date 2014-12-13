// ROM header including interrupt vectors

include "../../lib/snes_header.inc"

scope header {
constant MAP_MODE(MAP_SA1ROM)
constant CART_TYPE(CART_SA1 + CART_ROM_RAM)
constant ROM_SIZE(SIZE_256KiB)
constant SRAM_SIZE(SIZE_128KiB)

origin (($400<<ROM_SIZE)-1)
db $ff //fill rom

seek($FFB0)
    db 0, 0                 // B0 - Maker code
    db "ARM9"               // B2 - Game code
    fill 7, 0               // B6 - 7 byte filler
    db 0                    // BD - Ext cart RAM (for GSU carts), no$sns seems to ignore this unless licensee code is $33
    db 0                    // BE - Special version(?)
    db 0                    // BF - Cartridge sub-number(?)
    db "sa1 test             " // C0 - Game title 21 bytes
//     "                     "
seek($FFD5)
    db MAP_MODE             // D5 - Map mode
    db CART_TYPE            // D6 - Cart type
    db ROM_SIZE             // D7 - ROM size
    db SRAM_SIZE            // D8 - Cart RAM size
    db DEST_USA_CANADA      // D9 - Destination code (NTSC/PAL)
    db $33                  // DA - License code, some emulators care about this in edge cases, 0 or $33
    db $00                  // DB - Version number (v 1.xx)
    dw $1337,$ACE           // DC - Dummy checksum and complement
//------------------------------------------------
seek($FFE4)             // native vectors
    dw 0                // cop
    dw 0                // brk
    dw 0                // abort
    dw WRAM_NMI_VECTOR  // nmi
    dw 0                // unused
    dw WRAM_IRQ_VECTOR  // irq
    dw 0, 0             // -
seek($FFF4)             // emulation mode vectors
    dw 0                // cop
    dw 0                // unused
    dw 0                // abort
    dw 0                // nmi
    dw _start           // reset
    dw 0                // irq
}
// vim:ft=bass
