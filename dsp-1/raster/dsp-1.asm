
if (MAP_MODE&1) == 1 {
    constant _DSP_IO($806000) //HIROM
    constant _DSP_DATA_REG($806000)
    constant _DSP_STATUS_REG($807000) //Status register
} else {
    constant _DSP_IO($8000) //LOROM
    constant _DSP_DATA_REG($3F8000)
    constant _DSP_STATUS_REG($3FC000)
    constant _DSP_BANK($3F)
}

scope macro WaitRqm() {
_rqm{#}:
    bit.w _DSP_STATUS_REG // Only works when in banks $30-3F
    bpl _rqm{#} // bit 15 of DR register set when ready
}

scope macro WaitRqmLong() {
_rqml{#}:
    lda.l _DSP_STATUS_REG_LONG
    //and.w #$8000
    bpl _rqml{#} 
}

    loram()
_WRAM_HDMAEN:; fill 1

constant _OFFSET_CX(-128)
constant _OFFSET_CY(-112)

constant _hdma_matrix1_size((127<<2))
constant _hdma_matrix2_size((97<<2)+1)

//TODO: rewrite functions to use C DSP_Perspective and remove these
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

//TODO: write hdma routines
_hdmaMatrixPointerAB:; fill (1+2 + 1+2 + 1+2)//1 byte repeat, 2 byte pointer for each entry
_hdmaMatrixPointerCD:; fill (1+2 + 1+2 + 1+2)

_hdmaMatrixAB1:; fill _hdma_matrix1_size
_hdmaMatrixAB2:; fill _hdma_matrix2_size
_hdmaMatrixCD1:; fill _hdma_matrix1_size
_hdmaMatrixCD2:; fill _hdma_matrix2_size

__c_DSP_perspective_struct:;        db 0
__c_DSP_perspective_struct_x:;      dw 0
__c_DSP_perspective_struct_y:;      dw 0
__c_DSP_perspective_struct_z:;      dw 0
__c_DSP_perspective_struct_Lfe:;    dw 0
__c_DSP_perspective_struct_Les:;    dw 0
__c_DSP_perspective_struct_Aas:;    dw 0
__c_DSP_perspective_struct_Azs:;    dw 0
__c_DSP_perspective_struct_center_x:; dw 0
__c_DSP_perspective_struct_center_y:; dw 0
__c_DSP_perspective_struct_raster_center:; dw 0
__c_DSP_perspective_struct_horizon:; dw 0


    bank0()

//use during scanning
//DSP_perspective variables used, not modified:
//  x, y, z, Lfe, Les, Aas, Azs
//modified, not used:
//   rastercenter, horizon, center_x, center_y
dspUpdateProjection:
    php
    phb
    lda _libsfc_r0
    sep #$10
    ldx.b #_DSP_BANK
    phx
    plb
    
    ldx.b #$02
    stx.w _DSP_DATA_REG// Set up persp projection
    
    lda.l _cam_x
    sta.w _DSP_DATA_REG
    
    WaitRQM
    
    lda.l _cam_y
    sta.w _DSP_DATA_REG
    lda.l _cam_z
    sta.w _DSP_DATA_REG
    lda.l _cam_Lfe
    sta.w _DSP_DATA_REG
    lda.l _cam_Les
    sta.w _DSP_DATA_REG
    lda.l _cam_Aas
    sta.w _DSP_DATA_REG
    lda.l _cam_Azs
    sta.w _DSP_DATA_REG 
    
    WaitRQM // 839 cycle delay ie 117.4 microsec. 296 cpu cycles?
    
    lda.w _DSP_DATA_REG
    sta.l _rastercenter
    lda.w _DSP_DATA_REG
    sta.l _horizon
    NOP
    lda.w _DSP_DATA_REG
    sta.l _cam_cx
    lda.w _DSP_DATA_REG
    sta.l _cam_cy
    
    plb
    plp
    rts

//updates the HDMA table with perspective projection matrix parameters from DSP-1 raster function
dspRenderProjection:
    php
    phb
    
    sep #$10
    ldx.b #_DSP_BANK
    phx
    plb
    
    ldx.b #$0A
    stx.w _DSP_DATA_REG 
    stz.w _DSP_DATA_REG // start at scanline 0
    
    rep #$30
    ldy.w #$00C0 //($7F+$41)
    ldx.w #$0000
    
_loopRasterData1:
    
    WaitRQM
    // 200 dsp cycles delay per line
    lda.w _DSP_DATA_REG
    sta.l _hdmaMatrixAB1,x
    lda.w _DSP_DATA_REG
    sta.l _hdmaMatrixAB1+2,x
    lda.w _DSP_DATA_REG
    sta.l _hdmaMatrixCD1,x
    lda.w _DSP_DATA_REG
    sta.l _hdmaMatrixCD1+2,x
    inx
    inx
    inx
    inx
    
    dey
    bne _loopRasterData1
    
    WaitRQM
    
    lda.w #$8000
    sta _DSP_DATA_REG
    sta _DSP_DATA_REG
    sta _DSP_DATA_REG
    sta _DSP_DATA_REG
    
    plb
    plp
    rts

//void dspObjectProjection(unsigned int x, unsigned int y, unsigned int z, unsigned int *H, unsigned int *V, unsigned int *M)//
dspObjectProjection:
    
    sep #$20
    //lda.b #_DSP_BANK
    //pha
    //plb
    
    lda.b #$06 // Command for object projection, standard 6 cycles
    sta.l _DSP_DATA_REG_LONG
    
    rep #$21
    lda 4,s
    sta.l _DSP_DATA_REG_LONG // x, 12 cycles, or 4.1 scpu cycles
    lda 6,s // since accumulator is 16 bit this load takes 5 cycles and first write takes 4 cycles
    sta.l _DSP_DATA_REG_LONG // y, 4 cycles
    lda 8,s
    sta.l _DSP_DATA_REG_LONG // z, whooping 596 cycles
    
    lda 10,s // pointer to H
    sta.b tcc__r0
    lda 12,s // bank H
    sta.b tcc__r0h
    lda 14,s // pointer to V
    sta.b tcc__r1
    lda 16,s // bank V
    sta.b tcc__r1h
    lda 18,s // pointer to M
    sta.b tcc__r2
    lda 20,s // bank M
    sta.b tcc__r2h // 54 cycles
    
    //WaitRQM // 210.168-42 SCPU cycles, should branch roughly 20 times with above code in place
    WaitRQML
    //todo: this isn't right
    lda.w #$0080
    adc.l _DSP_DATA_REG_LONG // H scroll, 3 cycles
    sta.b tcc__r3
    lda.w #$0070
    clc
    adc.l _DSP_DATA_REG_LONG // V scroll, 2 cycles
    sta.b tcc__r3h
    lda.l _DSP_DATA_REG_LONG // Enlargement ratio, 4 cycles until the next command can be selected
    bmi +
    sta.b [tcc__r2]
    beq +
    sep #$20
    lda.b tcc__r3
    sta.b [tcc__r0]
    lda.b tcc__r3h
    sta.b [tcc__r1]
    bra ++
+   
    sep #$20
    lda.b #$E0
    sta.b [tcc__r0]
    sta.b [tcc__r1]
++  rep #$20
    rts


//call during nmi
//this routine could potentially be used with a precalculated matrix HDMA table,
//however you will need to supply your own raster_center
//DSP_perspective variables used, not modified:
//  center_x, center_y, _rastercenter, perhaps horizon if I find a use for it at some point
//pea.w :__tccs_camera // 2 : 10
//pea.w __tccs_camera + 0 // 2 : 8
//jsr.l dspUpdateCamera // 3 : 5
dspUpdateCameratemp:
    php
    phb //1 : 4
    
    phk
    plb
    //lda 8,s   // 4 cycles, stack relative
    //lda (0)   // 5 cycles dp indirect
    //lda [0]   // 6 cycles dp indirect long
    //lda (0,x) // 6 cycles, dp indexed indirect,x
    //lda (0),y // 5 cycles, dp indirect indexed,y
    //lda [0],y     // 6 cycles, dp indirect long indexed,y
    //lda (8,s),y // 7 cycles, stack relative indirect indexed long,y
    rep #$31
    
    lda.b 10,s // bank
    sta.b tcc__r0h
    lda.b 8,s // pointer
    adc.w #__c_DSP_perspective_struct_center_x
    sta.b tcc__r0
    
    // load the center_x var
    lda.b [tcc__r0] // 24-bit address to our value, may optimize by changing data bank to the one on the stack
    sta.l _libsfc_r0 //center_x
    
    lda.b tcc__r0 // 3 cycles
    ina // 2 cycles
    ina // 2 cycles
    sta.b tcc__r0 // 3 cycles
    lda.b [tcc__r0]
    sta.l _libsfc_r1 //center_y
    
    lda.b tcc__r0 // 3 cycles
    ina // 2 cycles
    ina // 2 cycles
    sta.b tcc__r0 // 3 cycles
    lda.b [tcc__r0]
    sta.l _libsfc_r2 //raster_center
    
    
    lda.l _libsfc_r1 //libsfc_r0
    tax
    sep #$20
    sta.w $2120
    xba
    sta.w $2120
    lda.l _libsfc_r0
    sta.w $211F
    lda.l _libsfc_r0+1
    sta.w $211F
    rep #$31
    lda.l _libsfc_r0
    adc.w #_OFFSET_CX
    sep #$21
    sta $210D
    xba
    sta $210D
    rep #$20
    txa
    sbc.l _libsfc_r2
    clc
    adc.w #_OFFSET_CY
    sep #$20
    sta.w $210E
    xba
    sta.w $210E
    
    plb
    plp
    rts

dspUpdateCamera:
    php
    phb
    
    phk
    plb
    
    sep #$20
    lda.l _cam_cx
    sta.w $211F
    lda.l _cam_cx+1
    sta.w $211F
    lda.l _cam_cy
    sta.w $2120
    lda.l _cam_cy+1
    sta.w $2120
    
    rep #$31
    lda.l _cam_cy
    tax
    lda.l _cam_cx
    adc.w #_OFFSET_CX
    sep #$21
    sta $210D
    xba
    sta $210D
    rep #$20
    txa
    sbc.l _rastercenter
    clc
    adc.w #_OFFSET_CY
    sep #$20
    sta $210E
    xba
    sta $210E
    
    plb
    plp
    rts

//following code needs rewrite in/for C
_setupMatrixHDMA:
    php
    phb
    
    rep #$10
    sep #$20
    
    lda.b #$7E
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
    //plb
    
    ldx.w #$1B43
    ldy.w #_hdmaMatrixPointerAB
    lda.b #:_hdmaMatrixPointerAB
    sta.l $4317
    jsl setupHDMAChannel1
    
    ldx.w #$1D43
    ldy.w #_hdmaMatrixPointerCD
    lda.b #:_hdmaMatrixPointerCD
    sta.l $4327
    jsl setupHDMAChannel2
    
    plb
    plp
    rts

_setupCamera:
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
    
    rts

_setupBGHDMA:
    php
    
    rep #$10
    sep #$20
    
    ldx #$0500
    ldy #_bgmode_hdma
    lda #:_bgmode_hdma
    jsl setupHDMAChannel3
    
    ldx #$2C00
    ldy #_tm_hdma
    lda #:_tm_hdma
    jsl setupHDMAChannel4
    
    plp
    rts

_bgmode_hdma:
.db 33 // skipping one scanline to minimize quantization errors on the horizon
.db $9
.db 1
.db $7
.db 0

_tm_hdma:
.db 33
.db $16
.db 1
.db $11
.db 0

//void dspSinCos(int Angle, unsigned int Radius, int *sin, int *cos)//
dspSinCos:
    //phb
    //phd
    
    sep #$20
    //lda.b #_DSP_BANK
    //pha
    //plb
    
    lda.b #$04
    sta.l _DSP_DATA_REG_LONG
    rep #$21
    lda 4,s //Angle
    sta.l _DSP_DATA_REG_LONG
    lda 6,s //Radius
    //It's safe to skip RQM check here
    sta.l _DSP_DATA_REG_LONG
    
    
    //tsc
    //adc.w #9
    //tcd
    //
    lda 8,s //pointer to sin
    sta.b tcc__r0
    lda 10,s //bank of pointer to sin
    sta.b tcc__r0h
    lda 12,s //pointer to cos
    sta.b tcc__r1
    lda 14,s //bank of pointer to cos
    sta.b tcc__r1h
    lda.l _DSP_DATA_REG_LONG
    sta.b [tcc__r0]
    lda.l _DSP_DATA_REG_LONG
    sta.b [tcc__r1]
    
    //pld
    //plb
    rts

//void dspRotate2D(int Angle, int *x, int *y)//
dspRotate2D:
    //phb
    
    sep #$20
    //lda.b #_DSP_BANK
    //pha
    //plb
    
    lda.b #$0C
    sta.l _DSP_DATA_REG_LONG
    rep #$20
    lda.b 4,s //Angle
    sta.l _DSP_DATA_REG_LONG
    lda.b 6,s //pointer to X
    sta.b tcc__r0
    lda.b 8,s //bank of pointer to X
    sta.b tcc__r0h
    lda.b 10,s //pointer to Y
    sta.b tcc__r1
    lda.b 12,s //bank of pointer to Y
    sta.b tcc__r1h
    lda.b [tcc__r0]
    sta.l _DSP_DATA_REG_LONG
    lda.b [tcc__r1]
    sta.l _DSP_DATA_REG_LONG
    
    //WaitRQM
    .rept 9
        nop
    .endr
    
    lda.l _DSP_DATA_REG_LONG
    sta.b [tcc__r0]
    lda.l _DSP_DATA_REG_LONG
    sta.b [tcc__r1]
    
    //plb
    rts

.ends

include "DSP-1/arithmetics.asm"
include "DSP-1/matrix.asm"
include "DSP-1/projection.asm"
//include "DSP-1/trigonometry.asm"
//include "DSP-1/vectors.asm"

// vim:ft=bass
