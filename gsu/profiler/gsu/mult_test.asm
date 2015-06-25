
    arch snes.gsu

multTest:
    iwt r12, #$2000
    cache
    move r13, r15
-;  loop    // 1 cycle
    mult r0 // 1 or 2 cycles

    stop
    nop

