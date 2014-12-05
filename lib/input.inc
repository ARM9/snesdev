
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
// vim:ft=bass
