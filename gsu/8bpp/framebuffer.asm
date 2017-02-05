
constant FRAMEBUFFER($702000)
constant FB_WIDTH(192)
constant FB_HEIGHT(160)
constant FB_BPP(8)  // bits per pixel
constant FB_SIZE(FB_WIDTH * FB_HEIGHT * FB_BPP / 8)

constant VRAM_SCREEN1($0000) // ] address of framebuffers in vram, in halfwords
constant VRAM_SCREEN2($4000) // ]
constant VRAM_FB_MAP($7C00)

    bank0()
include "../../lib/gsu/map_gen.asm"
scope fb_map: {
    ColumnMajorMap(FB_WIDTH, FB_HEIGHT, FB_BPP, 0, 0, 0x7fff, 4)
}


// vim:ft=snes
