
    arch snes.gsu

multTest:
    iwt r12, #$2000
    cache
    move r13, r15
-;  loop        // 1
    mult r0     // 1 or 2

    stop
    nop

umultTest:
    iwt r12, #$2000
    cache
    move r13, r15
-;
    umult r0    // 2 or 3
    loop        // 1
    nop         // 1

    stop
    nop

fmultTest:
    iwt r12, #$2000
    cache
    move r13, r15
-;
    loop        // 1
    fmult       // 4 or 8

    stop
    nop

lmultTest:
    iwt r12, #$2000
    cache
    move r13, r15
-;  
    lmult       // 5 or 9
    loop        // 1
    nop         // 1

    stop
    nop

