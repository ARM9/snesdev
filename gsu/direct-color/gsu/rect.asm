
    arch snes.gsu

scope drawRect: {
// returns: void
// args:
    // color r0
    define x1(r3)       // u8
    define y1(r4)       // u8
    define width(r5)    // u8
    define height(r6)   // u8
// vars:

// clobbers:
//  r1-r2,r7,r12-r13

    color
    move r2, {y1}
    move r7, {height}
    iwt r13, #x_loop
y_loop:
    move r1, {x1}
    move r12, {width}
    x_loop:
        loop
        plot
    dec r7
    bne y_loop
    inc r2

    ret
    nop
}

// vim:ft=snes
