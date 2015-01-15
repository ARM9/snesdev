scope header {
// Size predefs for ROM/RAM/SRAM fields
constant SIZE_NONE($00)
constant SIZE_2KiB($01)   // amount of cart RAM in Super Mario World
constant SIZE_4KiB($02)
constant SIZE_8KiB($03)
constant SIZE_16KiB($04)
constant SIZE_32KiB($05)  // Amount of cart RAM in Mario Paint
constant SIZE_64KiB($06)  // Amount of cart RAM in Stunt Race FX
constant SIZE_128KiB($07) // Amount of cart RAM in Dezaemon - Kaite Tsukutte Asoberu
constant SIZE_256KiB($08)
constant SIZE_512KiB($09) // Amount of ROM in Super Mario World
constant SIZE_1MiB($0A)   // Amount of ROM in Mario Paint
constant SIZE_2MiB($0B)   // Amount of ROM in Super Mario World 2
constant SIZE_4MiB($0C)   // Amount of ROM in Donkey Kong Country 2 and 3
// Valid range for ROM: $08-$0C, most emulators don't mind $05
// Valid range for cart RAM: $00-$07

// Map modes
constant MAP_LOROM($20) // LoROM
constant MAP_HIROM($21) // HiROM
constant MAP_FASTROM($10) // OR with one of the above for FastROM (3.58MHz)
constant MAP_EXHIROM($25) // ExHiROM + SlowROM
constant MAP_SA1ROM($23) // SA-1 ROM

// Cartridge types
constant CART_ROM($00)      // ROM only
constant CART_ROM_RAM($01)  // ROM+RAM
constant CART_ROM_RAM_BAT($02)  // ROM+RAM+Battery
// Coprocessors (add with one of the above)
constant CART_DSP1($03)     // DSP-1
constant CART_GSU($13)      // SuperFX
constant CART_OBC1($23)     // OBC-1
constant CART_SA1($33)      // SA-1
constant CART_OTHER($E3)    // \ Todo: determine out how/if emulators use these
constant CART_CUSTOM($F3)   // | to distinguish between obscure stuff like the
                            // / CX4, ST-0018, SPC7110 etc.

// Destination codes, most emulators use this to determine PAL/NTSC
constant DEST_JAPAN($00)
constant DEST_USA_CANADA($01)
constant DEST_EUROPE($02)
constant DEST_SCANDANAVIA($03)
constant DEST_FRENCH_EU($06)
constant DEST_DUTCH($07)
constant DEST_SPANISH($08)
constant DEST_GERMAN($09)
constant DEST_ITALIAN($0A)
constant DEST_CHINESE($0B)
constant DEST_KOREAN($0D)
constant DEST_COMMON($0E)
constant DEST_CANADA($0F)
constant DEST_BRAZIL($10)
constant DEST_AUSTRALIA($11)

}
// vim:ft=snes
