
    arch snes.gsu

    sram0()
max_x:; db 0
min_x:; db 0
max_y:; db 0
min_y:; db 0

    align(2)
edge_buffer:
    fill 192*(2)

    bank0()

scope drawTriangle: {
// returns: void
// args:
    define tri_ptr(r0)  // Tri_struct* r3
// vars:
    define v0(r3)
    define v1(r4)
    define v2(r5)
    define tmp(r9)
// clobbers:
// tbd

    //move r0, {tri_ptr}

    iwt {tmp}, #max_x
    ibt r12, #2
    move r13, r15
loop_vertices_minmax: {
    // find max and min x y coordinates
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
    // write x1 count to edge buffer
    
    // draw scanlines
    iwt r13, #x_loop
y_loop: {
    x_loop: {
        loop
        plot
    }

    bge y_loop
    nop
}

    ret
    nop
}

// vim:ft=snes
