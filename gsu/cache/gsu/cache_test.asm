
    arch snes.gsu

    include "../../../lib/gsu/gsu.inc"

    bank0()
multTest:
    iwt r12, #$2000
    // align cache so the next routine fits into the same cache line
    AlignCache()
    cache
    move r13, r15
-;  loop
    mult r0

    stop
    nop

multTestNoCache:
    iwt r12, #$2000
    move r13, r15
-;  loop
    mult r0

    stop
    nop

