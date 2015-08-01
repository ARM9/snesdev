
if !{defined _INPUT_INC} {
define _INPUT_INC(1)

constant PAD_R($0010)
constant PAD_L($0020)
constant PAD_X($0040)
constant PAD_A($0080)
constant PAD_RIGHT($0100)
constant PAD_LEFT($0200)
constant PAD_DOWN($0400)
constant PAD_UP($0800)
constant PAD_START($1000)
constant PAD_SELECT($2000)
constant PAD_Y($4000)
constant PAD_B($8000)
// MSB
constant PADH_RIGHT($01)
constant PADH_LEFT($02)
constant PADH_DOWN($04)
constant PADH_UP($08)
constant PADH_START($10)
constant PADH_SELECT($20)
constant PADH_Y($40)
constant PADH_B($80)

macro ReadJoypad(pad) {
    //a8
    //i16
    lda.b #1
L{#}:
    bit.w REG_HVBJOY
    bne L{#}
    ldx.w REG_JOY{pad}L
}

//-----------------------------------------------
    bss()
scope Joypad {
    __pads_held:
    __pad1_held:; dw 0

    __pads_prev:
    __pad1_prev:; dw 0

    __pads_pressed:
    __pad1_pressed:; dw 0

    __pads_released:
    __pad1_released:; dw 0
}
//-----------------------------------------------

    bank0()
scope Joypad: {

macro Pressed(pad) {
    //a16
    lda.w Joypad.__pad{pad}_pressed
}

macro Held(pad) {
    //a16
    lda.w Joypad.__pad{pad}_held
}

macro __ReadJoypad(padnum, held, prev, pressed) {
    lda.w {held}
    sta.w {prev}
    lda.w REG_JOY1L + ({padnum} * 2)
    sta.w {held}
    eor.w {prev}
    and.w {held}
    sta.w {pressed}
}

scope updatePads: {
// Call during vblank
// output: void
// input: void
    php
    rep #$30

    lda.w #$0001
-;  bit.w REG_HVBJOY
    bne -
    Joypad.__ReadJoypad(0, __pad1_held, __pad1_prev, __pad1_pressed)
    plp
    rts
}

}


}
// vim:ft=snes
