
    arch snes.gsu

    sram0()
_edge_buffer:
    fill 192*(2)

    bank0()
scope drawTriangle: {
// returns: void
// args:
define tri_ptr(r3)  // struct triangle* r3
// vars:
//  
// clobbers:
// tbd

    move r0, r3
    ibt r12, #3
    iwt r13, #loop_vertices
loop_vertices:
    to r1
    ldb (r0)
    // next vertex
    add #3
    to r2
    ldb (r0)
    // next vertex
    add #3
    to r4
    ldb (r0)

    // next coordinate
    sub #5
    loop
    nop

    move r13, r15
    loop
    plot

    ret
    nop
}

// vim:ft=snes
