
    arch snes.gsu

// Plot a rotated 16x16 sprite to beginning of framebuffer
scope rotate: {
// returns: void
// args:
//  s16 r3      = rotation (8.8)
//  u16* r14    = pointer to sprite in rom
// vars:
//	
// clobbers:
//	

//[ x2 ]  =  [cos(theta)  sin(theta)]  *  [ x1 ]
//[ y2 ]     [-sin(theta) cos(theta)]     [ y1 ]

//X2 = (Y1 * sin(Angle) >> 15) + (X1 * cos(Angle) >> 15);
//Y2 = (Y1 * cos(Angle) >> 15) - (X1 * sin(Angle) >> 15);
    
    ret
    nop
}

// vim:ft=bass