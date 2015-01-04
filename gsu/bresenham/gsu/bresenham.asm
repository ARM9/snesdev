
    arch snes.gsu

// Bresenham implementation
// plenty of room for optimizations, have fun
scope drawLine: {
// returns: void
// args:
    define x1(r1)   // s16
    define y1(r2)   // s16
    define x2(r3)   // s16
    define y2(r4)   // s16
// vars:
    define dx(r5)   // s16
    define dy(r6)   // s16
    define sx(r7)   // s16
    define sy(r8)   // s16
    define err(r9)  // s16
    define e2(r12)  // s16
// clobbers:
//  r0-r9, r12

    // dx = abs(x2 - x1);
    from {x2}; sub {x1}
    bpl +; nop
        not; inc r0
+;  move {dx}, r0

    // dy = abs(y2 - y1);
    from {y2}; sub {y1}
    bpl +; nop
        not; inc r0
+;  move {dy}, r0

    // sx = x1 < x2 ? 1 : -1;
    ibt {sx}, #0
    from {x1}; sub {x2}; blt +; inc {sx}
        dec {sx}; dec {sx}
+
    // sy = y1 < y2 ? 1 : -1;
    ibt {sy}, #0
    from {y1}; sub {y2}; blt +; inc {sy}
        dec {sy}; dec {sy}
+
    // err = (dy >= dx ? -dy : dx) / 2;
    from {dy}; sub {dx}
    bge +; with {err}
        from {dx}
        bra ++; with {err}
+
        from {dy}; 
        with {err}; not; inc {err}
        with {err}
+;  div2

L0: // while(1){
    plot
    dec {x1}

    // if(x1==x2 && y1==y2) break;
    from {x1}; sub {x2}; bne +
    from {y1}; sub {y2}; bne +; nop
        ret; nop
+
    // e2 = err;
    move {e2}, {err}
    // if (e2 < dy)  { err += dx; y1 += sy; }
    from {e2}; sub {dy}; bge +; with {e2}
        with {err}; add {dx}
        with {y1}; add {sy}
        with {e2}
+
    // if (-e2 < dx) { err -= dy; x1 += sx; }
    not; inc {e2}
    from {e2}; sub {dx}; bge L0
        with {err}; sub {dy}
        with {x1};
    bra L0
    add {sx}
    // }
}
BlockSize(drawLine)
// vim:ft=bass
