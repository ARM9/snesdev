
constant hdma_matrix1_size((127<<2))
constant hdma_matrix2_size((97<<2)+1)

    bss()
hdmaMatrixPointerAB:; fill (1+2 + 1+2 + 1+2)//1 byte repeat, 2 byte pointer for each entry
hdmaMatrixPointerCD:; fill (1+2 + 1+2 + 1+2)

hdmaMatrixAB1:; fill hdma_matrix1_size
hdmaMatrixAB2:; fill hdma_matrix2_size
hdmaMatrixCD1:; fill hdma_matrix1_size
hdmaMatrixCD2:; fill hdma_matrix2_size

    bank0()
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
dspUpdateMatrixTable:
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

include "dsp-1/arithmetic.asm"
include "dsp-1/matrix.asm"
include "dsp-1/projection.asm"
include "dsp-1/trigonometry.asm"
//include "dsp-1/vectors.asm"

// vim:ft=bass
