
macro seek(variable offset) {
    origin (offset & $3FFFFF)
    base offset
}

    arch snes.cpu
include "segments.inc"
include "header.inc"
include "../../lib/snes_regs.inc"
include "../../lib/zpage.inc"
    bank0()
constant _STACK_TOP($2ff)
include "../../lib/snes_init.inc"

include "assets.asm"
include "data.asm"
//-------------------------------------
    bank0()
_start:
    InitSnes()

//-------------------------------------
    bank0()
include "../../lib/dma.inc"
include "../../lib/ppu.inc"
include "../../lib/hdma.inc"
include "interrupts.asm"
//-------------------------------------

    zpage()
frame_count:; dw 0

    bss()
nmitimen_mirror:; db 0

scope Camera: {
x:;     dw 0
y:;     dw 0
cx:;    dw 0
cy:;    dw 0
fov:;   dw 0
}

wram_matrixA:; fill $10
wram_matrixB:; fill $10
wram_matrixC:; fill $10

    bank0()
scope main: {
    rep #$10
    sep #$20

    jsr initVideo
    jsr initMatrixHdma
    jsr initCamera

    ldx.w #$0500
    ldy.w #bgmode_hdma
    lda.b #bgmode_hdma>>16
    jsr HDMA.initChannel5

    ldx.w #$2C00
    ldy.w #tm_hdma
    lda.b #tm_hdma>>16
    jsr HDMA.initChannel6

    jsr Interrupts.init

_forever:
    wai
    jmp _forever
}

scope initVideo: {
    php
    rep #$10; sep #$20
    
    LoadLoVram(donut.map7, $0000, donut.map7.size)
    LoadHiVram(donut.chr7, $0000, donut.chr7.size)
    LoadCgram(donut.pal, $00, donut.pal.size)

    stz.w REG_BG1SC
    lda.b #$78
    sta.w REG_BG2SC
    lda.b #$70
    sta.w REG_BG12NBA

    lda.b #$77
    sta.w REG_BG34NBA

    lda.b #$78
    sta.w REG_BG3SC
    lda.b #$7C
    sta.w REG_BG4SC

    lda.b #$07
    sta.w $2105

    lda.b #$C0
    sta.w $211A

    lda.b #$01
    sta.w $212C

    lda.b #$0F
    sta.w inidisp_mirror

    plp
    rts
}

scope initMatrixHdma: {
    // todo less magic numbers
    php
    rep #$10; sep #$20

    lda.b #32
    sta.w wram_matrixA
    sta.w wram_matrixB
    sta.w wram_matrixC
    ldx.w #$0000
    stx.w wram_matrixA+1
    stx.w wram_matrixB+1
    stx.w wram_matrixC+1

    lda.b #$E1
    sta.w wram_matrixA+3
    sta.w wram_matrixB+3
    sta.w wram_matrixC+3

    stz.w wram_matrixA+6
    stz.w wram_matrixB+6
    stz.w wram_matrixC+6

    ldx.w #$1B42
    ldy.w #wram_matrixA
    lda.b #$00
    jsr HDMA.initChannel1
    lda.b #hdmaMatrixALUT>>16
    sta.w $4317

    ldx.w #$1C42
    ldy.w #wram_matrixB
    lda.b #$00
    jsr HDMA.initChannel2
    lda.b #hdmaMatrixALUT>>16
    sta.w $4327

    ldx.w #$1D42
    ldy.w #wram_matrixC
    lda.b #$00
    jsr HDMA.initChannel3
    lda.b #hdmaMatrixALUT>>16
    sta.w $4337

    ldx.w #$1E42
    ldy.w #wram_matrixA
    lda.b #$00
    jsr HDMA.initChannel4
    lda.b #hdmaMatrixALUT>>16
    sta.w $4347
    
    plp
    rts
}

scope initCamera: {
    php
    rep #$20

    lda.w #-128
    sta.w Camera.x
    lda.w #64
    sta.w Camera.y
    lda.w #256/2
    sta.w Camera.cx
    lda.w #192
    sta.w Camera.cy

    lda.w #32
    sta.w Camera.fov

    plp
    rts
}
// vim:ft=snes
