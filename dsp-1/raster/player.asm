
    bss()
scope Player: {
    x:;         dw 0
    y:;         dw 0
    z:;         dw 0
    y_rot:;     dw 0
    torque:;    dw 0
    velocity:;  dw 0
}
//-------------------------------------
    bank0()
scope Player {
constant VELOCITY_MAX($50)
constant TORQUE_MAX($70)
constant Z_MAX($100)
constant Z_MIN($10)

scope init: {
    php
    rep #$30

    lda.w #$A00
    sta.w Player.x
    lda.w #$1200
    sta.w Player.y
    lda.w #$20
    sta.w Player.z

    plp
    rts
}

scope update: {
    php
    rep #$30

    Joypad.Held(1)
    sta.b zp7

//-------------------------------------
    bit.w #PAD_UP
    beq _up_up
        lda.w Player.velocity
        cmp.w #Player.VELOCITY_MAX
        bcs +
            inc
            sta.w Player.velocity
            bra +
_up_up:
    lda.w Player.velocity
    cmp.w #1
    bcc +
    dec
    sta.w Player.velocity
+

//-------------------------------------
    lda.b zp7
    bit.w #PAD_LEFT
    beq _left_up
        lda.w Player.torque
        cmp.w #-TORQUE_MAX
        beq +
            dec #4; sta.w Player.torque
            bra +
_left_up:
    lda.w Player.torque
    beq +
    bpl +
    inc #4; sta.w Player.torque
+

//-------------------------------------
    lda.b zp7
    bit.w #PAD_RIGHT
    beq _right_up
        lda.w Player.torque
        cmp.w #TORQUE_MAX
        beq +
        inc #4; sta.w Player.torque
        bra +
_right_up:
    lda.w Player.torque
    beq +
    bmi +
    dec #4; sta.w Player.torque
+
//-------------------------------------
    lda.b zp7
    bit.w #PAD_Y
    beq _Y_up
        lda.w Player.z
        cmp.w #Z_MAX
        bcs +
            inc; sta.w Player.z
_Y_up:

+
//-------------------------------------
    lda.b zp7
    bit.w #PAD_B
    beq _B_up
        lda.w Player.z
        cmp.w #Z_MIN
        bcc +
            dec; sta.w Player.z
_B_up:

+
//-------------------------------------
    lda.b zp7
    bit.w #PAD_L
    beq _L_up
        lda.w Camera.Lfe
        cmp.w #$1f
        bcc +
            sec; sbc.w #$10
            sta.w Camera.Lfe
_L_up:

+
//-------------------------------------
    lda.b zp7
    bit.w #PAD_R
    beq _R_up
        lda.w Camera.Lfe
        cmp.w #$800
        bcs +
            clc; adc.w #$10
            sta.w Camera.Lfe
_R_up:

+
//-------------------------------------
    lda.b zp7
    bit.w #PAD_X
    beq _X_up
        lda.w Camera.Les
        cmp.w #$11
        bcc +
            dec; sta.w Camera.Les
+
        lda.w Camera.Azs
        cmp.w #$4000
        beq +
            clc; adc.w #$40
            sta.w Camera.Azs
_X_up:

+

//-------------------------------------
    lda.b zp7
    bit.w #PAD_A
    beq _A_up
        lda.w Camera.Les
        cmp.w #$80
        bcs +
            inc; sta.w Camera.Les
+
        lda.w Camera.Azs
        cmp.w #-$1000
        beq +
            sec; sbc.w #$40
            sta.w Camera.Azs
_A_up:

+
//-------------------------------------
    lda.w Player.torque
    asl #2
    clc
    adc.w Player.y_rot
    sta.w Player.y_rot
    tax

    lda.w Player.velocity
    beq _skip
    and.w #$00ff
    xba
    tay
    jsr dspSinCos
    phy // cos

    // Player.x += Player.velocity * sin(y_rot)
    ldy.w Player.velocity
    jsr dspMult16

    stx.b zp0
    lda.w Player.x
    clc
    adc.b zp0
    sta.w Player.x

    // Player.y += Player.velocity * cos(y_rot)
    plx // cos
    ldy.w Player.velocity
    jsr dspMult16
    stx.w zp0
    lda.w Player.y
    sec
    sbc.b zp0
    sta.w Player.y
_skip:

    plp
    rts
}
}
// vim:ft=bass
