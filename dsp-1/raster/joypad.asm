
constant JOYPADS_MAX(4)

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

//-----------------------------------------------
    bss()
scope Joypad {
__num_joypads:; db 0
__pads_held:
__pads1_held:; dw 0
__pads2_held:; dw 0
__pads3_held:; dw 0
__pads4_held:; dw 0

__pads_prev:
__pads1_prev:; dw 0
__pads2_prev:; dw 0
__pads3_prev:; dw 0
__pads4_prev:; dw 0

__pads_down:
__pads1_down:; dw 0
__pads2_down:; dw 0
__pads3_down:; dw 0
__pads4_down:; dw 0

__pads_released:
__pads1_released:; dw 0
__pads2_released:; dw 0
__pads3_released:; dw 0
__pads4_released:; dw 0
}
//-----------------------------------------------

    bank0()
scope Joypad: {

macro Init(num_pads) {
    //a8
    lda.b #{num_pads}
    sta.w Joypad.__num_joypads
}

pressed:
// returns:
//  a16 = buttons pressed
// args:
//  a8 = joypad number
    php

    rep #$30
    and.w #$000F
    asl
    tax
    
    lda.w __pads_down,x
    plp
    rts

held:
// returns:
//  a16 = buttons held
// args:
//  a8 = joypad number
    php

    rep #$30
    and.w #$000F
    asl
    tax

    lda.w __pads_held,x
    plp
    rts

scope updatePads: {
// returns: void
// args: void
    php

    rep #$30
    lda.w __num_joypads
    and.w #$000F
    beq +
    dec
    asl
    tax

    lda.w #$01
-;  bit.w $4212
    bne -
_read_next:
    jmp (__readJoypad_jmptable,x)
_fast_return:
    dex
    dex
    bpl _read_next
+
    plp
    rts
}

macro __ReadJoypad(padnum, held, prev, down) {
    lda.w {held}
    sta.w {prev}
    lda.w $4218 + ({padnum} * 2)
    sta.w {held}
    eor.w {prev}
    and.w {held}
    sta.w {down}
    jmp updatePads._fast_return
}

__readJoypad_jmptable:
dw __readJoypad1
dw __readJoypad2
dw __readJoypad3
dw __readJoypad4
//dw _readJoypad5
//dw _readJoypad6
//dw _readJoypad7
//dw _readJoypad8

__readJoypad1:
    __ReadJoypad(0, __pads1_held, __pads1_prev, __pads1_down)

__readJoypad2:
    __ReadJoypad(1, __pads2_held, __pads2_prev, __pads2_down)

__readJoypad3:
    __ReadJoypad(2, __pads3_held, __pads3_prev, __pads3_down)

__readJoypad4:
    __ReadJoypad(3, __pads4_held, __pads4_prev, __pads4_down)
}

// vim:ft=bass
