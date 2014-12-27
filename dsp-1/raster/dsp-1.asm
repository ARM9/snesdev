
constant OFFSET_CX(-128)
constant OFFSET_CY(-112)

constant hdma_matrix1_size((127<<2))
constant hdma_matrix2_size((97<<2)+1)

    bss()
scope Camera: {
x:; dw 0// [CI] horizontal
y:; dw 0// [CI] depth
z:; dw 0// [CI] vertical
Lfe:; dw 0// [U] Distance between base point and viewpoint (Sets screen-sprite ratio)
Les:; dw 0// [U] fov, Distance between viewpoint and screen (the effect of screen angle considered; screen horizontal distance 256)
Aas:; dw 0// [A] Azimuth angle, rotation around Y axis
Azs:; dw 0// [A] Zenith angle, X/Z rotationish
cx:; dw 0//\ [CI] focal point
cy:; dw 0///
raster_center:; dw 0 // [I]
horizon:; dw 0 // [I]
}

hdmaMatrixPointerAB:; fill (1+2 + 1+2 + 1+2)//1 byte repeat, 2 byte pointer for each entry
hdmaMatrixPointerCD:; fill (1+2 + 1+2 + 1+2)

hdmaMatrixAB1:; fill hdma_matrix1_size
hdmaMatrixAB2:; fill hdma_matrix2_size
hdmaMatrixCD1:; fill hdma_matrix1_size
hdmaMatrixCD2:; fill hdma_matrix2_size

    bank0()

scope Camera {
scope init: {
    php
    rep #$30

    lda.w #200
    sta.l Camera.x
    lda.w #200
    sta.l Camera.y
    lda.w #48
    sta.l Camera.z

    lda.w #$100
    sta.l Camera.Lfe
    lda.w #$20
    sta.l Camera.Les
    lda.w #$6000 // rotation around Y axis
    sta.l Camera.Aas
    lda.w #$3f00
    sta.l Camera.Azs

    plp
    rts
}
}
//DSP_perspective variables used, not modified:
//  x, y, z, Lfe, Les, Aas, Azs
//modified:
//   rastercenter, horizon, center_x, center_y
dspUpdateProjection:
    php
    sep #$10
    rep #$20

    ldx.b #$02
    stx.w REG_DSP_DATA// Set up persp projection

    lda.w Camera.x
    sta.w REG_DSP_DATA

    WaitRQM()

    lda.w Camera.y
    sta.w REG_DSP_DATA
    lda.w Camera.z
    sta.w REG_DSP_DATA
    lda.w Camera.Lfe
    sta.w REG_DSP_DATA
    lda.w Camera.Les
    sta.w REG_DSP_DATA
    lda.w Camera.Aas
    sta.w REG_DSP_DATA
    lda.w Camera.Azs
    sta.w REG_DSP_DATA

    WaitRQM() // 839 cycle delay ie 117.4 microsec. 296 cpu cycles?

    lda.w REG_DSP_DATA
    sta.w Camera.raster_center
    lda.w REG_DSP_DATA
    sta.w Camera.horizon
    nop
    lda.w REG_DSP_DATA
    sta.w Camera.cx
    lda.w REG_DSP_DATA
    sta.w Camera.cy

    plp
    rts

//updates the HDMA table with perspective projection matrix parameters from DSP-1 raster function
dspRenderProjection:
    php
    sep #$20

    lda.b #$0A
    sta.w REG_DSP_DATA
    rep #$30
    stz.w REG_DSP_DATA // start at scanline 0

    ldy.w #$00C0 //($7F+$41)
    ldx.w #$0000

_loopRasterData1:
    WaitRQM()
    // 200 dsp cycles delay per line
    lda.w REG_DSP_DATA
    sta.w hdmaMatrixAB1,x
    lda.w REG_DSP_DATA
    sta.w hdmaMatrixAB1+2,x
    lda.w REG_DSP_DATA
    sta.w hdmaMatrixCD1,x
    lda.w REG_DSP_DATA
    sta.w hdmaMatrixCD1+2,x

    inx; inx; inx; inx
    dey
    bne _loopRasterData1

    WaitRQM()

    // tell dsp we're done
    lda.w #$8000
    sta.w REG_DSP_DATA
    sta.w REG_DSP_DATA
    sta.w REG_DSP_DATA
    sta.w REG_DSP_DATA

    plp
    rts

//void dspObjectProjection(unsigned int x, unsigned int y, unsigned int z, unsigned int *H, unsigned int *V, unsigned int *M)//
dspObjectProjection:
    php
    sep #$20
    //lda.b #DSP_BANK
    //pha
    //plb

    //lda.b #$06 // Command for object projection, standard 6 cycles
    //sta.l REG_DSP_DATA

    plp
    rts

//call during nmi
dspUpdateCamera:
    php

    rep #$31

    lda.w Camera.cy
    tay
    lda.w Camera.cx
    sep #$20
    sta.w REG_M7X
    xba
    sta.w REG_M7X
    xba
    rep #$21
    adc.w #OFFSET_CX
    sep #$20
    sta REG_BG1HOFS
    xba
    sta REG_BG1HOFS

    rep #$20
    tya
    sep #$21 // set carry for "free"
    sta.w REG_M7Y
    xba
    sta.w REG_M7Y
    xba
    rep #$20
    sbc.w Camera.raster_center
    clc
    adc.w #OFFSET_CY
    sep #$20
    sta.w REG_BG1VOFS
    xba
    sta.w REG_BG1VOFS

    plp
    rts

initMatrixHdma:
    php
    phb

    rep #$10
    sep #$20

    lda.b #hdmaMatrixPointerAB>>16
    pha
    plb

    ldx.w #hdmaMatrixAB1
    stx.w hdmaMatrixPointerAB+4//&$FFFF+4
    ldx.w #hdmaMatrixAB2
    stx.w hdmaMatrixPointerAB+7//&$FFFF+7

    ldx.w #hdmaMatrixCD1
    stx.w hdmaMatrixPointerCD+4//&$FFFF+4
    ldx.w #hdmaMatrixCD2
    stx.w hdmaMatrixPointerCD+7//&$FFFF+7

    lda.b #32
    sta.w hdmaMatrixPointerAB//&$FFFF
    sta.w hdmaMatrixPointerCD//&$FFFF
    lda #$FF//127 lines with repeat
    sta.w hdmaMatrixPointerAB+3//&$FFFF+3
    sta.w hdmaMatrixPointerCD+3//&$FFFF+3
    lda.b #$C1  //$41|$80 $40 lines with repeat
    sta.w hdmaMatrixPointerAB+6//&$FFFF+6
    sta.w hdmaMatrixPointerCD+6//&$FFFF+6

    plb
    ldx.w #$1B43
    ldy.w #hdmaMatrixPointerAB
    lda.b #hdmaMatrixPointerAB>>16
    sta.w $4317
    jsr HDMA.initChannel1

    ldx.w #$1D43
    ldy.w #hdmaMatrixPointerCD
    lda.b #hdmaMatrixPointerCD>>16
    sta.w $4327
    jsr HDMA.initChannel2

    plp
    rts

initBgHdma:
    php

    rep #$10
    sep #$20

    ldx.w #$0500
    ldy.w #bgmode_hdma
    lda.b #bgmode_hdma>>16
    jsr HDMA.initChannel3

    ldx.w #$2C00
    ldy.w #tm_hdma
    lda.b #tm_hdma>>16
    jsr HDMA.initChannel4

    plp
    rts

bgmode_hdma:
db 33 // skipping one scanline to minimize quantization errors on the horizon
db $9
db 1
db $7
db 0

tm_hdma:
db 33
db 0//$16
db 1
db $11
db 0

dspSinCos:
// returns:
//  x16 = sin(angle)
//  y16 = cos(angle)
// args:
//  x16 = angle
//  y16 = radius
    //a8
    //i16
    php

    sep #$20
    lda.b #$04
    sta.w REG_DSP_DATA

    rep #$21
    stx.w REG_DSP_DATA // angle
    // safe to skip RQM check here
    sty.w REG_DSP_DATA // radius

    ldx.w REG_DSP_DATA // radius*sin(angle)
    ldy.w REG_DSP_DATA // radius*cos(angle)

    plp
    rts

dspRotate2D:
// returns:
//  x16 = x2
//  y16 = y2
// args:
//  zp0 = u16 angle
//  x16 = x1
//  y16 = y1
    //a8
    //i16
    php

    sep #$20
    lda.b #$0C
    sta.w REG_DSP_DATA

    rep #$20
    lda.b zp0
    sta.w REG_DSP_DATA
    stx.w REG_DSP_DATA
    sty.w REG_DSP_DATA

    //WaitRQM()
    nop; nop; nop
    nop; nop; nop
    nop; nop; nop

    ldx.w REG_DSP_DATA
    ldy.w REG_DSP_DATA

    plp
    rts

include "dsp-1/arithmetics.asm"
include "dsp-1/matrix.asm"
include "dsp-1/projection.asm"
//include "dsp-1/trigonometry.asm"
//include "dsp-1/vectors.asm"

// vim:ft=bass
