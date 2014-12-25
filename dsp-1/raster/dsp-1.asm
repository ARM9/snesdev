
include "../../lib/dsp-1/regs.inc"

constant OFFSET_CX(-128)
constant OFFSET_CY(-112)

constant hdma_matrix1_size((127<<2))
constant hdma_matrix2_size((97<<2)+1)

    bss()
_cam_x:; dw 0// [CI] horizontal
_cam_y:; dw 0// [CI] depth
_cam_z:; dw 0// [CI] vertical
_cam_Lfe:; dw 0// [U] Distance between base point and viewpoint (Sets screen-sprite ratio)
_cam_Les:; dw 0// [U] fov, Distance between viewpoint and screen (the effect of screen angle considered// screen horizontal distance 256)
_cam_Aas:; dw 0// [A] Azimuth angle, rotation around Y axis
_cam_Azs:; dw 0// [A] Zenith angle, X/Z rotationish
_cam_cx:; dw 0//\ [CI] focal point
_cam_cy:; dw 0///
_rastercenter:; dw 0 // [I]
_horizon:; dw 0 // [I]

_hdmaMatrixPointerAB:; fill (1+2 + 1+2 + 1+2)//1 byte repeat, 2 byte pointer for each entry
_hdmaMatrixPointerCD:; fill (1+2 + 1+2 + 1+2)

_hdmaMatrixAB1:; fill hdma_matrix1_size
_hdmaMatrixAB2:; fill hdma_matrix2_size
_hdmaMatrixCD1:; fill hdma_matrix1_size
_hdmaMatrixCD2:; fill hdma_matrix2_size

//perspective:;        db 0
//perspective_x:;      dw 0
//perspective_y:;      dw 0
//perspective_z:;      dw 0
//perspective_Lfe:;    dw 0
//perspective_Les:;    dw 0
//perspective_Aas:;    dw 0
//perspective_Azs:;    dw 0
//perspective_center_x:; dw 0
//perspective_center_y:; dw 0
//perspective_raster_center:; dw 0
//perspective_horizon:; dw 0

    bank0()
//use during scanning
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

    lda.w _cam_x
    sta.w REG_DSP_DATA

    WaitRQM()

    lda.w _cam_y
    sta.w REG_DSP_DATA
    lda.w _cam_z
    sta.w REG_DSP_DATA
    lda.w _cam_Lfe
    sta.w REG_DSP_DATA
    lda.w _cam_Les
    sta.w REG_DSP_DATA
    lda.w _cam_Aas
    sta.w REG_DSP_DATA
    lda.w _cam_Azs
    sta.w REG_DSP_DATA

    WaitRQM() // 839 cycle delay ie 117.4 microsec. 296 cpu cycles?

    lda.w REG_DSP_DATA
    sta.w _rastercenter
    lda.w REG_DSP_DATA
    sta.w _horizon
    nop
    lda.w REG_DSP_DATA
    sta.w _cam_cx
    lda.w REG_DSP_DATA
    sta.w _cam_cy

    plp
    rts

//updates the HDMA table with perspective projection matrix parameters from DSP-1 raster function
dspRenderProjection:
    php

    ldx.b #$0A
    stx.w REG_DSP_DATA
    stz.w REG_DSP_DATA // start at scanline 0

    rep #$30
    ldy.w #$00C0 //($7F+$41)
    ldx.w #$0000

_loopRasterData1:

    WaitRQM()
    // 200 dsp cycles delay per line
    lda.w REG_DSP_DATA
    sta.l _hdmaMatrixAB1,x
    lda.w REG_DSP_DATA
    sta.l _hdmaMatrixAB1+2,x
    lda.w REG_DSP_DATA
    sta.l _hdmaMatrixCD1,x
    lda.w REG_DSP_DATA
    sta.l _hdmaMatrixCD1+2,x

    inx; inx; inx; inx
    dey
    bne _loopRasterData1

    WaitRQM()

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
    //lda.b #_DSP_BANK
    //pha
    //plb

    //lda.b #$06 // Command for object projection, standard 6 cycles
    //sta.l REG_DSP_DATA

    plp
    rts

//call during nmi
dspUpdateCameratemp:
    php

    rep #$31

    lda.w _rastercenter
    sta.b zp0

    lda.w _cam_cx
    tax

    lda.w _cam_cy
    tay

    sep #$20
    sta.w REG_M7Y
    xba
    sta.w REG_M7Y

    rep #$20
    txa
    sep #$20
    sta.w REG_M7X
    xba
    sta.w REG_M7X

    rep #$31
    txa
    adc.w #OFFSET_CX
    sep #$21
    sta REG_BG1HOFS
    xba
    sta REG_BG1HOFS
    rep #$20
    tya
    sbc.b zp0
    clc
    adc.w #OFFSET_CY
    sep #$20
    sta.w REG_BG1VOFS
    xba
    sta.w REG_BG1VOFS

    plp
    rts

setupMatrixHDMA:
    php
    phb

    rep #$10
    sep #$20

    lda.b #_hdmaMatrixPointerAB>>16
    pha
    plb

    ldx.w #_hdmaMatrixAB1
    stx.w _hdmaMatrixPointerAB+4//&$FFFF+4
    ldx.w #_hdmaMatrixAB2
    stx.w _hdmaMatrixPointerAB+7//&$FFFF+7

    ldx.w #_hdmaMatrixCD1
    stx.w _hdmaMatrixPointerCD+4//&$FFFF+4
    ldx.w #_hdmaMatrixCD2
    stx.w _hdmaMatrixPointerCD+7//&$FFFF+7

    lda.b #32
    sta.w _hdmaMatrixPointerAB//&$FFFF
    sta.w _hdmaMatrixPointerCD//&$FFFF
    lda #$FF//127 lines with repeat
    sta.w _hdmaMatrixPointerAB+3//&$FFFF+3
    sta.w _hdmaMatrixPointerCD+3//&$FFFF+3
    lda.b #$C1  //$41|$80 $40 lines with repeat
    sta.w _hdmaMatrixPointerAB+6//&$FFFF+6
    sta.w _hdmaMatrixPointerCD+6//&$FFFF+6

    plb
    ldx.w #$1B43
    ldy.w #_hdmaMatrixPointerAB
    lda.b #_hdmaMatrixPointerAB>>16
    sta.w $4317
    jsr setupHDMAChannel1

    ldx.w #$1D43
    ldy.w #_hdmaMatrixPointerCD
    lda.b #_hdmaMatrixPointerCD>>16
    sta.w $4327
    jsr setupHDMAChannel2

    plp
    rts

setupCamera:
    php
    rep #$30

    lda.w #25
    sta.l _cam_x
    lda.w #25
    sta.l _cam_y
    lda.w #64
    sta.l _cam_z

    lda.w #$80
    sta.l _cam_Lfe
    lda.w #$40
    sta.l _cam_Les
    lda.w #$0000 // rotation around Y axis
    sta.l _cam_Aas
    lda.w #$3f00
    sta.l _cam_Azs

    plp
    rts

setupBGHDMA:
    php

    rep #$10
    sep #$20

    ldx.w #$0500
    ldy.w #bgmode_hdma
    lda.b #bgmode_hdma>>16
    jsr setupHDMAChannel3

    ldx.w #$2C00
    ldy.w #tm_hdma
    lda.b #tm_hdma>>16
    jsr setupHDMAChannel4

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
db $16
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
    lda.b #_DSP_BANK; pha; plb

    lda.b #$04
    sta.w REG_DSP_DATA
    rep #$21
    stx.w REG_DSP_DATA // angle
    // safe to skip RQM check here
    sty.w REG_DSP_DATA // radius

    ldx.w REG_DSP_DATA // radius*sin(angle)
    ldy.w REG_DSP_DATA // radius*cos(angle)

    rts

//void dspRotate2D(int angle, int *x, int *y)//
dspRotate2D:
// returns:
//  x16 = x2
//  y16 = y2
// args:
//  u16 zp0 = angle
//  x16     = x1
//  y16     = y1
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
