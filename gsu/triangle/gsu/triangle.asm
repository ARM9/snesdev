
    arch snes.gsu

    sram0()
    max_x:; db 0
    min_x:; db 0
    max_y:; db 0
    min_y:; db 0

    align(2)
TriangleBuffer:

    align(2)
edge_buffer:
    fill 192*(2)

    bank0()

scope drawTriangle: {
// returns: void
// args:
    define tri_ptr(r3)  // Tri_struct* r3
// vars:
    define rx(r1)
    define ry(r2)
    define count(r3)    //
    define v0(r4)
    define v1(r5)
    define v2(r6)
    define vt(r7)   // temporary vector/whatever storage
    define imm(r8)
    define tmp(r9)
// clobbers:
// tbd

    move r0, {tri_ptr}

    iwt {tmp}, #max_x
    ibt r12, #2
    move r13, r15
loop_vertices: {
    // v0.x v1.x v2.x 
    to {v0}
    ldb (r0)
    // next vertex
    add #2
    to {v1}
    ldb (r0)
    // next vertex
    add #2
    to {v2}
    ldb (r0)

    // max coord
    max({v0}, {v1})//; move {vt}, r0
    max(r0, {v2})
    stb ({tmp})
    inc {tmp}

    // min coord
    min({v0}, {v1})
    min(r0, {v2})
    stb ({tmp})
    inc {tmp}

    // next coordinate
    sub #3
    loop
    nop
}

    // num scanlines
    // v0 = max_x
    // v1 = min_x
    lm r0, (max_y)
    to {v0}; lob    // max y
    to {ry}; hib      // min y
    // count = max_x - min_x
    to r12; from {ry}; sub {v0}
    iwt r13, #x_loop
y_loop: {
    // todo: store scan lengths 
    lm {rx}, (max_x)
    to {v1}; lob    // max x
    to {rx}; hib    // min x
    x_loop: {
        loop
        plot
    }
    todo   with {rx}; sub r12
    lm {rx}, (edge_buffer)

    inc {ry}
    from {v0}; sub {ry}
    bge y_loop
    nop
}

    ret
    nop
}

// vim:ft=snes
