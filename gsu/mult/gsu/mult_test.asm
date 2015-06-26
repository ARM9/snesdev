
    arch snes.gsu

    bank0()
multTest:
    iwt r1, #$aaaa
    iwt r2, #$aaaa
    iwt r12, #$2000
    cache
    move r13, r15
-;
    from r1     // 1
    mult r2     // 1 or 2 cycles
    loop        // 1 cycle
    nop         // 1

    stop
    nop

    fill 16
umultTest:
    iwt r1, #$aaaa
    iwt r2, #$aaaa
    iwt r12, #$2000
    cache
    move r13, r15
-;
    from r1     // 1
    umult r2    // 2 or 3
    loop        // 1
    nop         // 1

    stop
    nop

    fill 16
fmultTest:
    iwt r1, #$aaaa
    iwt r6, #$aaaa
    iwt r12, #$2000
    cache
    move r13, r15
-;
    from r1     // 1
    fmult       // 4 or 8
    loop        // 1
    nop         // 1

    stop
    nop

    fill 16
lmultTest:
    iwt r1, #$aaaa
    iwt r6, #$aaaa
    iwt r12, #$2000
    cache
    move r13, r15
-;  
    from r1     // 1
    lmult       // 5 or 9
    loop        // 1
    nop         // 1

    stop
    nop

