
macro InitSnes() {
    sei; clc; xce
    jml _init_snes
}

_init_snes:
    phk; plb
    rep #$38

    ldx #>_STACK_TOP
    txs

    lda #$0000
    tcd

    sep #$20              // Set 8 bit accumulator

    lda #<(header.MAP_MODE>>4)&1 // Set fast rom access if fastrom
    sta.w REG_MEMSEL

    lda #$8f              // Force v-blank
    sta $2100

    stz $2101             // Sprite register (size + address in VRAM)
    stz $2102             // Sprite registers (address of sprite memory)
    stz $2103             // Sprite registers (address of sprite memory)
    stz $2105             // Set graphics Mode 0
    stz $2106             // No planes, no mosiac
    stz $2107             // Plane 0 map VRAM location ($0000 VRAM)
    stz $2108             // Plane 1 map VRAM location
    stz $2109             // Plane 2 map VRAM location
    stz $210a             // Plane 3 map VRAM location
    stz $210b             // Plane 0 and 1 tile data location
    stz $210c             // Plane 2 and 3 tile data location
    stz $210d             // Plane 0 scroll x (first 8 bits)
    stz $210d             // Plane 0 scroll x (last 3 bits) write to reg twice
    stz $210e             // Plane 0 scroll y (first 8 bits)
    stz $210e             // Plane 0 scroll y (last 3 bits) write to reg twice
    stz $210f             // Plane 1 scroll x (first 8 bits)
    stz $210f             // Plane 1 scroll x (last 3 bits) write to reg twice
    stz $2110             // Plane 1 scroll y (first 8 bits)
    stz $2110             // Plane 1 scroll y (last 3 bits) write to reg twice
    stz $2111             // Plane 2 scroll x (first 8 bits)
    stz $2111             // Plane 2 scroll x (last 3 bits) write to reg twice
    stz $2112             // Plane 2 scroll y (first 8 bits)
    stz $2112             // Plane 2 scroll y (last 3 bits) write to reg twice
    stz $2113             // Plane 3 scroll x (first 8 bits)
    stz $2113             // Plane 3 scroll x (last 3 bits) write to reg twice
    stz $2114             // Plane 3 scroll y (first 8 bits)
    stz $2114             // Plane 3 scroll y (last 3 bits) write to reg twice

    stz $211b             // Mode 7 matrix parameter A register (low)
    lda #$01
    sta $211b             // Mode 7 matrix parameter A register (high)
    stz $211c             // Mode 7 matrix parameter B register (low)
    stz $211c             // Mode 7 matrix parameter B register (high)
    stz $211d             // Mode 7 matrix parameter C register (low)
    stz $211d             // Mode 7 matrix parameter C register (high)
    stz $211e             // Mode 7 matrix parameter D register (low)
    sta $211e             // Mode 7 matrix parameter D register (high)

    stz $211f             // Mode 7 matrix parameter D register (high)
    stz $211f             // Mode 7 center position X register (high)
    stz $2120             // Mode 7 center position Y register (low)
    stz $2120             // Mode 7 center position Y register (high)
    stz $2123             // BG1 & BG2 Window mask setting register
    stz $2124             // BG3 & BG4 Window mask setting register
    stz $2125             // OBJ & Color Window mask setting register
    stz $2126             // Window 1 left position register
    stz $2127             // Window 2 left position register
    stz $2128             // Window 3 left position register
    stz $2129             // Window 4 left position register
    stz $212a             // BG1, BG2, BG3, BG4 Window Logic register
    stz $212b             // OBJ, Color Window Logic Register (or,and,xor,xnor)
    stz $212c             // Main Screen designation (planes, sprites enable)
    stz $212d             // Sub Screen designation
    stz $212e             // Window mask for Main Screen
    stz $212f             // Window mask for Sub Screen

    lda #$30
    sta $2130             // Color addition & Screen addition init setting

    stz $2131             // Add/Sub sub designation for screen, sprite, color

    lda #$e0              // Color data for addition/subtraction
    sta $2132

    stz $2133             // Color data for addition/subtraction

    stz $4016

    stz $4200             // Reset V-blank, interrupt, joypad register

    lda #$ff
    sta $4201             // Programmable I/O Port

    stz $4202             // Multiplicand A
    stz $4203             // Multiplier B
    stz $4204             // Multiplier C
    stz $4205             // Multiplicand C
    stz $4206             // Divisor B
    stz $4207             // HTIMEL
    stz $4208             // HTIMEH
    stz $4209             // VTIMEL
    stz $420a             // VTIMEH
    stz $420b             // General DMA enable (bits 0-7)
    stz $420c             // Horizontal DMA (HDMA) enable (bits 0-7)
    //stz $420d           // ROM speed (slow/fast)

// Clear OAM
    ldx #$0080
    lda #$e0

-;  sta $2104
    sta $2104
    stz $2104
    stz $2104
    dex
    bne -

    ldx #$0020
-;  stz $2104
    dex
    bne -

// Clear WRAM
    ldy #$0000
    sty $2181             // Transfer to $7E:0000
    stz $2183             // Select first WRAM bank ($7E)

    ldx #$8008            // Fixed source byte write to $2180
    stx $4300

    ldx #>CONST_ZERO      // load the low 16 bits of address to $0000 in rom
    lda #<CONST_ZERO>>16  // load the bank byte
    stx $4302             // DMA destination address
    sta $4304             // Destination bank
    sty $4305             // Transfer 64KiB

    lda #$01
    sta $420b
    nop
    sta $420b             // $2181-$2183 and $4305 wrap appropriately

//VRAM
    lda #$80
    sta $2115             // increment VRAM address on writes to $2119
    ldy #$0000
    sty $2116             // begin at address $0000 in VRAM

    // $4302, $4303 and $4304 haven't changed, so no need to reset them
    sty $4305             // transfer $10000 bytes

    ldx #$1809            // alternate byte writes to $2118/$2119 fixed source
    stx $4300

    lda #$01
    sta $420b

    // stz $2119 // Is this really necessary?

//CGRAM
    stz $2121
    ldx #>$200 // 512 bytes
    stx $4305
    ldx #$2208 // write a byte at a time to $2122 from fixed source
    stx $4300

    sta $420b

    jml main

CONST_ZERO:
    dw $0000

// vim:ft=bass
