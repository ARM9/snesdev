
//void dspSetAttitudeA(int scalar, DSP_vec3 *rot)//
dspSetAttitudeA:
	sep #$20
	
	lda.b #$01
	sta.l _DSP_DATA_REG_LONG
	rep #$21
	//lda.b 4,s // scalar
	lda.w #$7FFF
	sta.l _DSP_DATA_REG_LONG
	
	lda.b 6,s // pointer to X
	sta.b tcc__r0
	adc.w #$0002 // pointer to Y
	sta.b tcc__r1
	inc a
	inc a
	//clc
	//adc.w #$0002 // Z
	sta.b tcc__r2
	lda.b 8,s //bank of pointer to vec3
	sta.b tcc__r0h
	sta.b tcc__r1h
	sta.b tcc__r2h
	
	lda.b [tcc__r0]
	sta.l _DSP_DATA_REG_LONG
	lda.b [tcc__r1]
	clc
	adc.w #$C000
	sta.l _DSP_DATA_REG_LONG
	//lda.b [tcc__r2]
	lda.w #$0000
	sta.l _DSP_DATA_REG_LONG
	
	WaitRQML
	
	//lda.l _DSP_DATA_REG_LONG
	//sta.b [tcc__r0]
	//lda.l _DSP_DATA_REG_LONG
	//sta.b [tcc__r1]
	//lda.l _DSP_DATA_REG_LONG
	//sta.b [tcc__r2]
	
	rtl

//void dspObj2GlobalA(DSP_vec3 *obj, DSP_vec3 *global)//
dspObj2GlobalA: // Subjective A
	sep #$20
	
	lda.b #$03
	sta.l _DSP_DATA_REG_LONG
	rep #$21
	
	lda.b 4,s //pointer to F
	sta.b tcc__r0
	adc.w #$0002 //pointer to L
	sta.b tcc__r1
	clc
	adc.w #$0002 //pointer to U
	sta.b tcc__r2
	lda.b 6,s //bank of pointer to struct
	sta.b tcc__r0h
	sta.b tcc__r1h
	sta.b tcc__r2h
	
	lda.b [tcc__r0] //F
	sta.l _DSP_DATA_REG_LONG
	//lda.b [tcc__r1] //L
	lda.w #$0000
	sta.l _DSP_DATA_REG_LONG
	//lda.b [tcc__r2] //U
	sta.l _DSP_DATA_REG_LONG
	
	lda.b 8,s //pointer to X
	sta.b tcc__r0
	clc
	adc.w #$0002 //pointer to Y
	sta.b tcc__r1
	clc
	adc.w #$0002 //pointer to Z
	sta.b tcc__r2
	lda.b 10,s //bank of pointer to struct
	sta.b tcc__r0h
	sta.b tcc__r1h
	sta.b tcc__r2h
	
	lda.b [tcc__r0]
	sbc.l _DSP_DATA_REG_LONG
	sta.b [tcc__r0]
	
	lda.b [tcc__r1]
	sbc.l _DSP_DATA_REG_LONG
	sta.b [tcc__r1]
	
	clc
	lda.b [tcc__r2]
	adc.l _DSP_DATA_REG_LONG
	bmi +
	sta.b [tcc__r2]
	bra ++
+	eor #$FFFF
	inc a
	sta.b [tcc__r2]
++	sec
	lda #$0400
	sbc.b [tcc__r0]
	sta.b [tcc__r0]
	
	rtl
	
	

//int dspInnerProductA(DSP_vec3 *vector)//
dspInnerProductA:

	rtl

//void dspGlobal2ObjA(DSP_vec3 *global, DSP_vec3 *obj)//
dspGlobal2ObjA:

	rtl

.ends

.section "libsfc_dsp-1_matrix_B" superfree
//void dspSetAttitudeB(int scalar, DSP_vec3 *rot)//
dspSetAttitudeB:
	
	rtl

//void dspObj2GlobalB(DSP_vec3 *obj, DSP_vec3 *global)//
dspObj2GlobalB:
	
	rtl

//int dspInnerProductB(DSP_vec3 *vector)//
dspInnerProductB:

	rtl

//void dspGlobal2ObjB(DSP_vec3 *global, DSP_vec3 *obj)//
dspGlobal2ObjB:

	rtl

.ends


.section "libsfc_dsp-1_matrix_C" superfree
//void dspSetAttitudeC(int scalar, DSP_vec3 *rot)//
dspSetAttitudeC:
	
	rtl

//void dspObj2GlobalC(DSP_vec3 *obj, DSP_vec3 *global)//
dspObj2GlobalC:
	
	rtl

//int dspInnerProductC(DSP_vec3 *vector)//
dspInnerProductC:

	rtl

//void dspGlobal2ObjC(DSP_vec3 *global, DSP_vec3 *obj)//
dspGlobal2ObjC:

	rtl

// vim:ft=bass
