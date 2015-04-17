
    arch snes.gsu

multTest:
    iwt r12, #$2000
    cache
    move r13, r15
-;  loop
    mult r0
    stop
    nop

