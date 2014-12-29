
macro seek(variable offset) {
    origin ((offset & $7f0000) >> 1) | (offset & $7fff)
    base offset
}

    arch snes.cpu
include "segments.inc"
include "header.inc"
include "../../lib/snes_regs_dsp1.inc"
include "../../lib/zpage.inc"
    bank0()
constant _STACK_TOP($2ff)
include "../../lib/snes_init.inc"

include "assets.asm"
//-------------------------------------

    bank0()
_start:
    InitSnes()

//-------------------------------------
    bank0()
include "../../lib/ppu.inc"
include "../../lib/mem.inc"
include "../../lib/timing.inc"
include "../../lib/hdma.inc"
include "interrupts.asm"
include "joypad.asm"
include "dsp-1.asm"
//-------------------------------------

    zpage()
frame_counter:;     fill 1

    bss()
inidisp_mirror:;    fill 1
nmitimen_mirror:;   fill 1

scope Player: {
    x:;         dw 0
    y:;         dw 0
    torque:;    dw 0
    velocity:;  dw 0
}
//-------------------------------------

    bank0()
scope main: {
    rep #$10
    sep #$20

    lda.b #DSP_BANK; pha; plb

    Joypad.Init(1)

    jsr initVideo

    jsr Camera.init
    jsr initMatrixHdma
    jsr initBgHdma

    jsr Interrupts.init

_forever:
    rep #$30
    jsr Player.update
    jsr dspUpdateProjection
    jsr dspRenderProjection
    wai
    bra _forever
}

scope Player {
scope update: {
    php
    rep #$30

    lda.w #0
    jsr Joypad.held
    sta.b zp7

    bit.w #PAD_B
    //beq _b_up
        //lda.w Player.velocity
        //cmp.w #16
        //bcs +
            //inc
            //sta.w Player.velocity
            //bra +
//_b_up:
    //lda.w Player.velocity
    //cmp #1
    //bcc +
    //dec.w Player.velocity
//+

    lda.b zp7
    bit.w #PAD_LEFT
    beq _left_up
        lda.w Player.torque
        cmp #-64
        beq +
        dec; sta.w Player.torque
        bra +
_left_up:
    lda.w Player.torque
    beq +
    bit.w #$8000 // negative?
    beq +
    inc; sta.w Player.torque
+

    lda.b zp7
    bit.w #PAD_RIGHT
    beq _right_up
        lda.w Player.torque
        cmp #64
        beq +
        inc; sta.w Player.torque
        bra +
_right_up:
    lda.w Player.torque
    beq +
    bit.w #$8000
    bne +
    dec; sta.w Player.torque
+
    // 
    ldx.w Player.torque
    lda.w Player.velocity
    xba
    tay
    jsr dspSinCos
    phy // cos

    // Camera.x += Player.velocity * sin(torque)
    ldy.w Player.velocity
    jsr dspMult16
    
    stx.b zp0
    lda.w Camera.x
    clc
    adc.b zp0
    sta.w Camera.x

    // Camera.y += Player.velocity * cos(torque)
    plx // cos
    ldy.w Player.velocity
    jsr dspMult16
    stx.w zp0
    lda.w Camera.y
    clc
    adc.b zp0
    sta.w Camera.y
    
    plp
    rts
}
}

scope initVideo: {
    php
    rep #$10; sep #$20

    LoadLoVram(koop.map7, $0000, koop.map7.size)
    LoadHiVram(koop.chr7, $0000, koop.chr7.size)
    LoadCgram(koop.pal, 0, koop.pal.size)

    lda.b #$00
    sta.w REG_BG1SC
    lda.b #$4000>>10
    sta.w REG_BG2SC
    sta.w REG_BG3SC
    sta.w REG_BG4SC
    lda.b #($4000>>12)<<8
    sta.w REG_BG12NBA
    sta.w REG_BG34NBA

    lda.b #$07
    sta.w REG_BGMODE

    lda.b #$01
    sta.w REG_TM

    // set mode7 stuff
    lda.b #$C0
    sta.w REG_M7SEL

    lda.b #$05
    stz.w REG_M7A
    sta.w REG_M7A
    stz.w REG_M7D
    sta.w REG_M7D

    lda.b #$0F
    sta.w inidisp_mirror
    plp
    rts
}

// vim:ft=bass
