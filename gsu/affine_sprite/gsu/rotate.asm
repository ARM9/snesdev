
    arch snes.gsu

// Plot a rotated sprite to beginning of framebuffer
scope drawRotatedSprite: {
// returns: void
// args:
define angle(r3)    // s8 angle
define width(r4) // only square sprites
define gfx_ptr(r9)
//  r3      = s16 rotation (8.8)
// vars:
define x1(r1)
define y1(r2)
define tcos_sin(r3) // packed
define hwidth(r6)
define ty(r7)
define tx(r8)
//	
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
    // tcos_sin = sin8[angle&0xff]
    to r6; getb

    //cos(angle)
    ibt r0, #64
    add {angle}
    lob
    iwt {angle}, #lut.sin8
    to r14; add {angle}
    // tcos_sin = sin8[(angle+64)&0xff]
    to {tcos_sin}; from r6; getbh

    // hwidth = width/2, hheight = height/2;
    to {hwidth}; from {width}; lsr

    //for(int y = 0; y < height; y++)
_loopy:
    iwt r13, #_loopx
    
    //for(int x = 0; x < width; x++)

    move r12, {width}
_loopx:

    popr(11)
    ret
    nop
}

// vim:ft=snes
