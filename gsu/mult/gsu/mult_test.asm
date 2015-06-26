
    arch snes.gsu

    include "../../../lib/gsu/gsu.inc"

    bank0()
    AlignCache()
multTest:
    cache
    iwt r1, #$aaaa
    iwt r2, #$aaaa
    iwt r12, #$2000
    move r13, r15
-;
    from r1     // 1
    mult r2     // 1 or 2 cycles
    loop        // 1 cycle
    nop         // 1

    stop
    nop

    fill 16
    AlignCache()
umultTest:
    cache
    iwt r1, #$aaaa
    iwt r2, #$aaaa
    iwt r12, #$2000
    move r13, r15
-;
    from r1     // 1
    umult r2    // 2 or 3
    loop        // 1
    nop         // 1

    stop
    nop

    fill 16
    AlignCache()
fmultTest:
    cache
    iwt r1, #$aaaa
    iwt r6, #$aaaa
    iwt r12, #$2000
    move r13, r15
-;
    from r1     // 1
    fmult       // 4 or 8
    loop        // 1
    nop         // 1

    stop
    nop

    fill 16
    AlignCache()
lmultTest:
    cache
    iwt r1, #$aaaa
    iwt r6, #$aaaa
    iwt r12, #$2000
    move r13, r15
-;  
    from r1     // 1
    lmult       // 5 or 9
    loop        // 1
    nop         // 1

    stop
    nop

