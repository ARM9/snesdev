
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

    bank0()
    align(8)
    db "start"
_gsu_start:

    AlignCache()
    cache
scope gsu_main: {
    lms r0, (framebuffer_status) // check if framebuffer dma has completed
    ror
    bcc draw
     nop
    iwt r15, #dont_draw
     nop
draw:
        ibt r0, #$ff
        jal fillScreen
        nop

        //reset regs
        ibt r1, #64
        ibt r2, #64
        ibt r0, #0
        cmode
        color
        // turn on high nibble and dither flags
        ibt r0, #%110
        cmode
        ibt r0, #0x21
        color //only high nibble is copied, COLORREG=0x20
        fill 16, 0x4c

        inc r2
        //reset regs
        ibt r1, #64
        ibt r0, #0
        cmode
        color
        // turn off high nibble flag
        ibt r0, #%010
        cmode
        ibt r0, #0x21
        color //TODO whole byte is copied, COLORREG=0x21, should be 0x01 or is book2 wrong as usual
        fill 16, 0x4c

// Bit 0 - Opaque flag
// When 0 and COLOR=0, the plot circuit refreshes only the X coordinate
// and no plot operation is performed. Normal plot operation is performed
// for anything other than 0.
// Dithering cannot be performed between a transparent color and a normal color (color 0 and any other??)
// Bit 1 - Dither flag
// Since the processing to determine whether or not a color is
// transparent is performed in parallel with the generation of plot
// data, dithering cannot be performed between a transparent color and
// a normal color. This mode can also be used in the 4-color mode.

    // test cmode 00, 01, 10, 11
        define x(r1)
        define y(r2)
        define height(r3)
        define width(r12)
        define cmr(r4) // color mode register
        ibt {cmr}, #0
        from {cmr}; cmode
        ibt r0, #0x20
        color
        ibt {y}, #32
-
        ibt {height}, #8

        from {cmr}; cmode
-
        ibt {x}, #32
        ibt {width}, #32
        move r13, r15
        loop
        plot

        inc {y}
        dec {height}
        bne -
         nop
        
        inc {cmr}
        from {cmr}; sub #4
        bne --
         nop
// same test, reverse colors
        ibt {cmr}, #0
        from {cmr}; cmode
        ibt r0, #0x02
        color
-
        ibt {height}, #8

        from {cmr}; cmode
-
        ibt {x}, #32
        ibt {width}, #32
        move r13, r15
        loop
        plot

        inc {y}
        dec {height}
        bne -
         nop
        
        inc {cmr}
        from {cmr}; sub #4
        bne --
         nop

        rpix // flush pixel cache

        stop
        nop

        iwt r15, #gsu_main
         nop
dont_draw:

    stop
    nop

    iwt r15, #gsu_main
     nop
}

scope fillScreen: {
// in:
//  u16 r0 = fill value
// out: void
// vars:
//  u16* r3 = screen base
// clobbers:
//  r3 r12 r13
    iwt r3, #FRAMEBUFFER
    iwt r12, #FRAMEBUFFER_SIZE/2
    move r13, {pc}
-
    stw (r3)
    inc r3
    loop
    inc r3

    ret
     nop
}

if pc()-gsu_main > 512 {
warning "program too big for cache"
}

include "../../../lib/lut/sin8.inc"
// vim:ft=snes
