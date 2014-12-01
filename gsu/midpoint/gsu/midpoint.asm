    arch snes.gsu

// midpoint algorithm implementation
scope drawCircle: {
// returns: void
// args:
    define x1(r3) // center x
    define y1(r4) // center y
    define radius(r5)
// vars:
    define x2(r6)
    define y2(r7)
    define err(r8)
//  err =
// clobbers:
//  r0-r8
    // int x2 = r;
    move {x2}, {radius}
    // int y2 = 0;
    ibt {y2}, #0
    // int err = 1 - x2;
    ibt r0, #1
    to {err}; sub {x2} // err = 1-x2
    // while(x2 >= y2){
_loop:
    from {x2}; sub {y2}
    blt _end
    to r1; from {x1}; add {x2}
    to r2; from {y1}; add {y2}
    plot

    to r1; from {x1}; add {y2}
    to r2; from {y1}; add {x2}
    plot

    to r1; from {x1}; sub {x2}
    to r2; from {y1}; add {y2}
    plot

    to r1; from {x1}; sub {y2}
    to r2; from {y1}; add {x2}
    plot

    to r1; from {x1}; sub {x2}
    to r2; from {y1}; sub {y2}
    plot

    to r1; from {x1}; sub {y2}
    to r2; from {y1}; sub {x2}
    plot

    to r1; from {x1}; add {x2}
    to r2; from {y1}; sub {y2}
    plot

    to r1; from {x1}; add {y2}
    to r2; from {y1}; sub {x2}
    plot
    
    // y2++;
    inc {y2}
    // if(err < 0){
    sub r0
    from {err}; sub r0
    bge +; sub r0
    // err += 2 * y2 + 1
    from {y2}; rol
    with {err}; add r0
    bra _loop
    inc {err}

+   // }else{
    // x2--;
    dec {x2}
    // err += 2 * (y2 - x2 + 1)
    from {y2}; sub {x2}
    inc r0
    rol
    with {err}
    bra _loop
    add r0
    // }

    // }
_end:
    ret
    nop
}

// vim:ft=bass
