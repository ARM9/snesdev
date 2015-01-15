
//void dspSetAttitudeA(int scalar, DSP_vec3 *rot)//
dspSetAttitudeA:
    sep #$20

    lda.b #$01
    sta.w REG_DSP_DATA
    rep #$21
    //lda.b 4,s // scalar
    lda.w #$7FFF
    sta.w REG_DSP_DATA

    lda 6,s // pointer to X
    sta.b zp0
    adc.w #$0002 // pointer to Y
    sta.b zp1
    inc
    inc
    //clc
    //adc.w #$0002 // Z
    sta.b zp2
    lda 8,s //bank of pointer to vec3
    //sta.b zp0h
    //sta.b zp1h
    //sta.b zp2h

    lda [zp0]
    sta.l REG_DSP_DATA
    lda [zp1]
    clc
    adc.w #$C000
    sta.l REG_DSP_DATA
    //lda.b [zp2]
    lda.w #$0000
    sta.l REG_DSP_DATA

    WaitRQM()

    //lda.l REG_DSP_DATA
    //sta.b [zp0]
    //lda.l REG_DSP_DATA
    //sta.b [zp1]
    //lda.l REG_DSP_DATA
    //sta.b [zp2]

    rts

//void dspObj2GlobalA(DSP_vec3 *obj, DSP_vec3 *global)//
dspObj2GlobalA: // Subjective A
    sep #$20

    lda.b #$03
    sta.w REG_DSP_DATA
    rep #$21

    lda 4,s //pointer to F
    sta.b zp0
    adc.w #$0002 //pointer to L
    sta.b zp1
    clc
    adc.w #$0002 //pointer to U
    sta.b zp2
    lda 6,s //bank of pointer to struct
    //sta.b zp0h
    //sta.b zp1h
    //sta.b zp2h

    lda [zp0] //F
    sta.w REG_DSP_DATA
    //lda.b [zp1] //L
    lda.w #$0000
    sta.w REG_DSP_DATA
    //lda.b [zp2] //U
    sta.w REG_DSP_DATA

    lda 8,s //pointer to X
    sta.b zp0
    clc
    adc.w #$0002 //pointer to Y
    sta.b zp1
    clc
    adc.w #$0002 //pointer to Z
    sta.b zp2
    lda 10,s //bank of pointer to struct
    sta.b zp0h
    sta.b zp1h
    sta.b zp2h

    lda [zp0]
    sbc.w REG_DSP_DATA
    sta [zp0]

    lda [zp1]
    sbc.w REG_DSP_DATA
    sta [zp1]

    clc
    lda [zp2]
    adc.w REG_DSP_DATA
    bmi +
    sta [zp2]
    bra ++
+;  eor.w #$FFFF
    inc
    sta [zp2]
+; sec
    lda.w #$0400
    sbc [zp0]
    sta [zp0]

    rts


//int dspInnerProductA(DSP_vec3 *vector)//
dspInnerProductA:

    rts

//void dspGlobal2ObjA(DSP_vec3 *global, DSP_vec3 *obj)//
dspGlobal2ObjA:

    rts

//void dspSetAttitudeB(int scalar, DSP_vec3 *rot)//
dspSetAttitudeB:

    rts

//void dspObj2GlobalB(DSP_vec3 *obj, DSP_vec3 *global)//
dspObj2GlobalB:

    rts

//int dspInnerProductB(DSP_vec3 *vector)//
dspInnerProductB:

    rts

//void dspGlobal2ObjB(DSP_vec3 *global, DSP_vec3 *obj)//
dspGlobal2ObjB:

    rts


//void dspSetAttitudeC(int scalar, DSP_vec3 *rot)//
dspSetAttitudeC:

    rts

//void dspObj2GlobalC(DSP_vec3 *obj, DSP_vec3 *global)//
dspObj2GlobalC:

    rts

//int dspInnerProductC(DSP_vec3 *vector)//
dspInnerProductC:

    rts

//void dspGlobal2ObjC(DSP_vec3 *global, DSP_vec3 *obj)//
dspGlobal2ObjC:

    rts

// vim:ft=snes
