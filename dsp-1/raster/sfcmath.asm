
.ramsection ".registers" bank 0 slot 1
__rand_seed1 dsb 2
__rand_seed2 dsb 2
;__rand_local0 dsb 2
.ends

.section "libsfc_sfcmath_assembly_code" superfree
; int rand();
;	A fast pseudo random number generator
; in: none
; out: int r
rand:
	;rep #$20
	lda.w __rand_seed2
	lsr
	clc
	adc.w __rand_seed1
	sta.w __rand_seed1
	eor.w #$000F
	sta.b tcc__r0
	lda.w __rand_seed2
	sec
	sbc.b tcc__r0
	sta.w __rand_seed2
	sta.b tcc__r0
	rtl

; in: int a
; out: none
srand:
	lda 4,s
	sta.w __rand_seed2
	lda.w __rand_seed1
	rol
	sta.w __rand_seed1
	;lda.w #$0005
	;sta.w __rand_seed2
	rtl
/*
;unsigned int sin(unsigned int a);
; range 0-255 degrees
sin:
	lda.b 4,s
	and.w #$00FF
	asl
	tax
	lda.l __sin_cos_table16,x
	sta.b tcc__r0
	rtl
;unsigned int cos(unsigned int a);
cos:
	lda.b 4,s
	adc.w #64
	and.w #$00FF
	asl
	tax
	lda.l __sin_cos_table16,x
	sta.b tcc__r0
	rtl


