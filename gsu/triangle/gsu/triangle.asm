
    arch snes.gsu

    sram0()
    max_x:; dw 0
    min_x:; dw 0
    max_y:; dw 0
    min_y:; dw 0
    max_z:; dw 0
    min_z:; dw 0

    align(2)
vertex_buffer:
    Tri_struct()

_edge_buffer:
    fill 192*(2)

    bank0()

scope drawTriangle: {
// returns: void
// args:
    define tri_ptr(r3)  // Tri_struct* r3
// vars:
    define x1(r1)
    define y1(r2)
    define vt(r4) // temporary vector/whatever storage
    define v0(r5)
    define v1(r6)
    define v2(r7)
    define tmp(r9)
// clobbers:
// tbd

    move r0, {tri_ptr}

    iwt {tmp}, #max_x
    ibt r12, #3
    move r13, r15
loop_vertices:
    to {v0}
    ldb (r0)
    // next vertex
    add #3
    to {v1}
    ldb (r0)
    // next vertex
    add #3
    to {v2}
    ldb (r0)

    max({v0}, {v1})
    //move {vt}, r0
    max(r0, {v2})

    stb ({tmp})
    inc {tmp}
    // next coordinate
    sub #5
    loop
    nop


    ret
    nop
}

// vim:ft=snes
