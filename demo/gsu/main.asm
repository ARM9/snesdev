
    arch snes.gsu

include "../../lib/gsu/gsu.inc"

    sram0()
line_x:;    fill 2
line_y:;    fill 2

scene:;         fill 2
constant scene_dirty($8000)

scene_timer:;   fill 2
constant scene_duration(4)

    bank0()
_gsu_start:
    ibt r0, #lut.sin8>>16
    romb

    jal srand
    rol

    sub r0
    cmode

    //ibt r0, #$ff
    jal fillScreen
    sub r0

    AlignCache()
    cache
scope gsu_main: {
    lms r0, (framebuffer_status) // check if framebuffer dma has completed
    ror
    bcc _draw
    nop
change_scene:
    //jal updateCoords
    //nop

    lms r0, (scene_timer)
    inc r0
    move r3, r0

    iwt r2, #30*scene_duration
    sbk
    sub r2
    bne + // r0 != r2
    nop

    ibt r5, #$81 // scene 1

    bra _store_scene
    nop
+
    iwt r2, #30*scene_duration*2
    move r0, r3
    sub r2
    bne _change_scene_end // r0 < r2
    nop 

    sub r0
    sms (scene_timer), r0

    ibt r5, #$80 // scene 0

_store_scene:
    sms (scene), r5

_change_scene_end:
    stop
    nop

    bra gsu_main
    nop

_draw:
    lms r0, (scene)
    move r5, r0
    rol
    bcc + // clear screen if needed
    nop
    //ibt r0, #$ff
    jal fillScreen
    sub r0
+
    move r0, r5
    and #1
    sms (scene), r0
    ror
    bcc line_scene
    nop

circle_scene:

    ibt r12, #7
    move r13, r15
//-
    lms r0, (line_x)
    move r5, r0
    lsr #2
    color

    move r0, r5
    lms r5, (sram_rand_seed1)
    with r5; and #15
    with r5; add #11
    lsr #4
    with r5; add r0

    iwt r3, #140
    ibt r4, #90
    jal drawCircle
    nop

    lms r0, (line_x)
    move r5, r0
    with r5; and #15
    with r5; add #15
    lsr #3
    with r5; add r0

    ibt r3, #69
    ibt r4, #70
    jal drawCircle
    nop

    jal updateCoords
    nop

    loop
    nop

    bra end_frame
    nop

line_scene:
    //lms r0, (scene_timer)
    //move r3, r0
    //lms r1, (line_x)
    //add r1
    //sbk
    //move r0, r3
    //lms r2, (line_y)
    //add r2
    //sbk

    jal rand
    nop

    // set up loop
    ibt r12, #10
    move r13, r15
//-
    lms r0, (line_x)
    move r5, r0
    lsr #2
    color

    dec r10; dec r10; from r12; stw (r10)

    lms r6, (sram_rand_seed2)
    iwt r0, #lut.sin8
    move r5, r0
    lms r1, (line_x)
    to r14; add r1
    ibt r9, #64
    from r1; add r9
    add r6
    lob
    to r3; getb

    to r14; add r5
    lms r2, (line_y)
    to r4
    getb
    jal drawLine
    nop

    jal updateCoords
    nop

    to r12; ldw (r10); inc r10
    loop
    inc r10

end_frame:
    rpix // flush pixel cache

    stop
    nop

    iwt r11, #gsu_main
    jmp r11
    nop
}

scope updateCoords: {
    lms r0, (line_x)
    inc r0
    lob
    sbk

    lms r0, (line_y)
    inc r0
    lob
    
    ret
    sbk
}
scope fillScreen: {
// returns: void
// args:
//  u16 r0 = fill value
// vars:
//  u16* r3 = screen base
// clobbers:
//  r3 r12 r13
    iwt r3, #FRAMEBUFFER
    iwt r12, #FRAMEBUFFER_SIZE/2
    move r13, {pc}
-
    stw (r3)
    inc r3
    loop
    inc r3

    ret
    nop
}

include "midpoint.asm"
include "bresenham.asm"
include "../../lib/gsu/rand.inc"
BlockSize(gsu_main)

include "../../lib/lut/sin8.inc"
// vim:ft=bass
