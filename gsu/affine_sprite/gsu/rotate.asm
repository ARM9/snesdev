
    arch snes.gsu

// Plot a rotated sprite to start of framebuffer
// only square sprites, width = height
scope drawRotatedSprite: {
// returns: void
// args:
define angle(r3)    // s8 angle
define width(r4)    // u8
define gfx_ptr(r5)  // u8*
// vars:
define x1(r1)       // u8
define y1(r2)       // u8
define tcos(r3)     // s8
define tsin(r6)     // s8

define tx(r9)       //
define ty(r11)      //

define xs(r8)       // \ texel coordinates for merge
define ys(r7)       // /
// clobbers:
//  r0-r9, 

//[ x2 ]  =  [cos(theta)  sin(theta)]  *  [ x1 ]
//[ y2 ]     [-sin(theta) cos(theta)]     [ y1 ]

//X2 = (Y1 * sin(Angle) >> 15) + (X1 * cos(Angle) >> 15);
//Y2 = (Y1 * cos(Angle) >> 15) - (X1 * sin(Angle) >> 15);

    pushr(11)

    //sin(angle)
    iwt r0, #lut.sin8
    to r14; add {angle}
    // start computing cos offset to give rom buffer some breathing room
    ibt r0, #64
    add {angle}
    lob
    // done with angle
    iwt {angle}, #lut.sin8
    // tsin = sin8[angle]
    to {tsin}; getb

    to r14; add {angle}
    // rom buffering, set up loop
    ibt {y1}, #0
    iwt r13, #_loopx
    // tcos = sin8[(angle+64)&0xff]
    to {tcos}; getb

    //for(int y = 0; y < height; y++)
_loopy: {
    //for(int x = 0; x < width; x++)
    ibt {x1}, #0
    move r12, {width}

    from {width}; lsr
    to {ty}; from {y1}; sub r0
    _loopx: {
        //r0 = width/2;
        //tx = x - r0;
        //ty = y - r0;
        from {width}; lsr
        to {tx}; from {x1}; sub r0

        //xs = (ty * tsin + tx * tcos) + hwidth;
        to {ys}; from {ty}; mult {tsin}
        //with {ys}; hib
        to {xs}; from {tx}; mult {tcos}
        //with {xs}; hib
        with {xs}; add {ys}
        with {xs}; add r0

        //ys = (ty * tcos - tx * tsin) + hheight;
        to {ys}; from {ty}; mult {tcos}
        //with {ys}; hib
        to {ty}; from {tx}; mult {tsin}
        //with {ty}; hib
        with {ys}; sub {ty}
        with {ys}; add r0

        //if(xs >= 0 && xs < width && ys >= 0 && ys < height) {
        bmi +; sub r0

        merge
        to r14; add {gfx_ptr}
        // buffer what we can
        moves {xs}, {xs}
        bmi +; sub r0
        from {xs}; sub {width}
        blt +; sub r0
        from {ys}; sub {width}
        blt +; sub r0
        //plot(x, y, gfx_ptr[ys * height + xs];
        getc
        loop
        plot
        bra _loopxexit
        //} else {
        // set pixel (x,y) transparent
    +
        sub r0; color
        loop
        plot
    }
_loopxexit:
    from {y1}; sub {width}
    bcc _loopy
    inc {y1}
    }

    popr(11)
    ret
    nop
}

// vim:ft=snes
