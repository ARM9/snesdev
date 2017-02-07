    arch snes.gsu

// inner loop best/worst case of number of instructions executed
// x inner loop best case: 10 worst: 12
// y inner loop best case: 13 worst: 13

// Better bresenham implementation
//align(16)
scope drawLine: {
// in:
define x1(r1)   // s16
define y1(r2)   // s16
define x2(r3)   // s16
define y2(r4)   // s16
// out: void
// vars:
define dx(r5)   // s16
define dy(r6)   // s16
define incy(r7) // s16
define i(r8)    // s16

    // if (x2 < x1) {
    from {x2}; sub {x1}
    bge +
     // NOTE `WITH` instruction in pipeline, B flag is reset by nop in next
     // branch delay slot
        // swap(x1,x2)
        move r5, {x1}   // use r5 as temporary reg as it's not used yet
        move {x1}, {x2}
        move {x2}, r5
        // swap(y1,y2)
        move r5, {y1}
        move {y1}, {y2}
        move {y2}, r5
    //}
+
    // }
    // int dx = abs(x2 - x1)
    bpl +
     nop
    not; inc r0
+
    move {dx}, r0

    // int dy = abs(y2 - y1)
    from {y2}; sub {y1}
    bpl +
     nop
    not; inc r0
+
    move {dy}, r0

    // if (x2 < x1) { incx = -1 } else { incx = 1 }
    // skip since incx is always 1 from above swap, x1 <= x2

    // if (y2 < y1) { incy = -1 } else { incy = 1 }
    // could merge this with y2-y1 above if bpl/bge holds true for all inputs
    // in both cases
    // if we limit input domain to unsigned integers 0-256/0-224/whatever then
    // we can use bpl for both
    from {y2}; sub {y1}
    bge +
     ibt {incy}, #-1
    bra ++
     nop
+
    db 1    // ibt {incy}, #1
+

    // plot(x1,y1)

    // if (dy < dx) {
    from {dy}; sub {dx}
    bge ymajor
     plot
    //     int err = dx / 2
        define err(r0)
        from {dx}; asr

        move {i}, {dx}
    //     for (int i = dx; i >= 0; --i) {
-
            dec {i}
            bmi end
    //         err = err - dy
            sub {dy}
    //         if (err < 0) {
            bpl +
    //             y1 = y1 + incy
                with {y1}; add {incy}
    //             err = err + dx
                add {dx}
    //         }
    +
    //         x1 = x1 + incx
    //         plot(x1,y1)
        bra -
         plot
    //     }

end:
    ret
     nop
    // } else {
ymajor:
    //     int err = dy / 2
        define err(r0)
        from {dy}; asr

        move {i}, {dy}
    //     for (int i = dy; i >= 0; --i) {
-
            dec {i}
            bmi end
    //         y1 = y1 + incy
            with {y1}; add {incy}
    //         err = err - dx
            sub {dx}
    //         if (err < 0) {
            bpl +
             nop
    //             err = err + dy
                add {dy}
    //             plot(x1,y1)
                bra -
                 plot
    //         } else {
    +
            // if we don't want to increment, decrement x1 instead since plot
            // auto increments
    //             x1 = x1 - incx
                dec {x1}
    //             plot(x1,y1)
                bra -
                 plot
    //         }

    //     }
    // }
}

// vim:ft=snes

