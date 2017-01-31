
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
// output: void
// input:
    define tri_ptr(r0)  // Tri_struct* r3
// vars:
    define v0(r3)
    define v1(r4)
    define v2(r5)
    define tmp(r9)
// clobbers:
// tbd

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
