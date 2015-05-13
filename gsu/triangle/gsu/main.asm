
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

macro Vec2_t() {
    db 0, 0
}
//macro Tri_struct(x0, y0, z0, x1, y1, z1, x2, y2, z2, color) {
macro Tri_struct() {
    db 0, 0, 0
    db 0, 0, 0
    db 0, 0, 0
    // color
    db 0
}
macro Mat3_struct() {
    db 1, 0, 0
    db 0, 1, 0
    db 0, 0, 1
    //pad
    db 0
}

    sram0()
mv_matrix:
    Mat3_struct()
my_tri_ram:
    Tri_struct()

    bank0()

_gsu_start:
    ibt r0, #lut.sin8>>16
    romb

    sub r0 // fast way to set r0 = 0
    cmode // cmode = 0, see lib/snes_regs_gsu.inc for further information
    ibt r0, #12
    color

    AlignCache()
    cache
scope gsu_main: {
    lms r0, (framebuffer_status) // check if framebuffer dma has completed
    ror
    bcs dont_draw
    nop
        ibt r0, #$ff
        jal fillScreen
        nop

        //iwt r0, #lut.sin8
        //move r5, r0

        // load identity matrix
        iwt r1, #$0010 //m12_11
        iwt r2, #$0000 //m21_13
        iwt r3, #$0010 //m23_22
        iwt r4, #$0000 //m32_31
        iwt r5, #$0010 //m00_33
        iwt r6, #my_tri_ram
        ibt r12, #3
        iwt r14, #equilateral
        jal mulMat3Vec3
        nop

        iwt r3, #my_tri_ram
        jal drawTriangle
        nop

        rpix // flush pixel cache

        stop
        nop

        bra gsu_main
        nop
dont_draw:

    stop
    nop

    bra gsu_main
    nop
}

scope fillScreen: {
// returns: void
// args:
//  u16 r0 = fill value
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

include "matrix3.asm"
include "triangle.asm"
BlockSize(gsu_main)

include "models.inc"
include "../../../lib/lut/sin8.inc"
// vim:ft=snes
