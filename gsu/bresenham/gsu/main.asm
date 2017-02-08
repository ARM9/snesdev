
    arch snes.gsu

include "../../../lib/gsu/gsu.inc"

macro DrawPixel(x, y, c) {
    ibt r0, #{c}
    color
    iwt r1, #{x}
    iwt r2, #{y}
    plot
}

macro DrawLine(x1, y1, x2, y2, c) {
    ibt r0, #{c}
    color
    iwt r1, #{x1}
    iwt r2, #{y1}
    iwt r3, #{x2}
    iwt r4, #{y2}
    jal drawLine
     nop
}

    sram0()
line_x:; fill 2
line_y:; fill 2

    bank0()
_gsu_start:
    ibt r0, #lut.sin8>>16
    romb

    sub r0 // fast way to set r0 = 0
    cmode // cmode = 0, see lib/snes_regs_gsu.inc for further information

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

        ibt r0, #12
        color

        iwt r0, #lut.sin8
        move r5, r0
        lms r1, (line_x)
        to r14; add r1  // r14 = sin8 + line_x
        ibt r9, #64
        from r1; add r9 // r0 = line_x + 64
        lob             // r0 &= 0xff
        to r3; getb     // r3 = [romb:r14]  sin(x)

        to r14; add r5  // r14 = r0 + sin8
        lms r2, (line_y)
        to r4; getb     // r4 = [romb:r14]  cos(x)
        jal drawLine
         nop

        define x1(220)
        define y1(190)
        define x2(2)
        define y2(50)

        DrawLine(1, 1, 1, 1, 4)

        DrawLine({x1}, {y1}, {x2}, {y2}, 4)
        DrawLine({x2}+2, {y2}, {x1}+2, {y1}, 6)

        DrawPixel({x1}, {y1}, 7)
        DrawPixel({x2}, {y2}, 7)

        DrawLine(100, 180, 220, 20, 5)
        DrawLine(10, 180, 212, 191, 5)

        // dy == dx
        define x1(10)
        define y1(10)
        define x2(60)
        define y2(60)
        DrawLine({x1}, {y1}, {x2}, {y2}, 4)
        DrawPixel({x1}-1, {y1}, 7)
        DrawPixel({x2}-1, {y2}, 7)

        // dy > dx
        define x1(101)
        define y1(20)
        define x2(100)
        define y2(80)
        DrawLine({x1}, {y1}, {x2}, {y2}, 4)
        DrawPixel({x1}-1, {y1}, 7)
        DrawPixel({x2}-1, {y2}, 7)

        // dy < dx
        define x1(20)
        define y1(5)
        define x2(100)
        define y2(9)
        DrawLine({x1}, {y1}, {x2}, {y2}, 4)
        DrawPixel({x1}, {y1}+1, 7)
        DrawPixel({x2}, {y2}+1, 7)

        rpix // flush pixel cache

        stop
        nop

        iwt r15, #gsu_main
         nop
dont_draw:
    lms r0, (line_x)
    inc r0
    lob
    sbk

    lms r0, (line_y)
    inc r0
    lob
    sbk

    stop
    nop

    iwt r15, #gsu_main
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

include "bresenham.asm"

include "../../../lib/lut/sin8.inc"
// vim:ft=snes
