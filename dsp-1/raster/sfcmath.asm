.include "hdr.asm"

.ramsection ".registers" bank 0 slot 1
__rand_seed1 dsb 2
__rand_seed2 dsb 2
;__rand_local0 dsb 2
.ends

.base $70
.ramsection ".sram.registers" bank 0 slot 4
__sram_rng_seed1 dsb 2
__sram_rng_seed2 dsb 2
.ends

.base $80
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

;unsigned char sin8(unsigned int a);
; range 0-255 degrees
sin8:
	lda.b 4,s
	and.w #$FF00
	xba
	tax
	lda.l __sin_cos_table8,x
	sta.b tcc__r0
	rtl

;unsigned char cos8(unsigned int a);
cos8:
	lda.b 4,s
	clc
	adc.w #$4000 ; 90 degrees
	and.w #$FF00
	xba
	tax
	lda.l __sin_cos_table8,x
	sta.b tcc__r0
	rtl
*/
;unsigned int umult8(unsigned char a, unsigned char b); args pushed onto stack from right to left
umult8:
	lda.b 4,s
	sep #$20
	sta.l $4202
	xba
	sta.l $4203
	rep #$20
	lda.l $4216 ;$4216-$4217 = 16-bit product for multiplication, finnishes ON 8th cycle
	;sadly have to read on 9th cycle because tcc doesn't optimize dbr use
	sta.b tcc__r0
	rtl

;signed int smult8(signed char a, signed char b);
smult8:
	lda.b 4,s
	sep #$20
	sta.l $4202
	xba
	sta.l $4203
	rep #$20
	lda.l $4216 ;$4216-$4217 = 16-bit product for multiplication, finnishes ON 8th cycle
	;sadly have to read on 9th cycle because tcc doesn't optimize dbr use
	sta.b tcc__r0
	rtl

;signed int smult16(signed int, signed int);
smult16:
	
	rtl

;unsigned int udiv16by8(unsigned int num, unsigned char denom);
udiv16by8:
	lda 4,s
	sta.l $4204
	sep #$20
	lda 6,s
	sta.l $4206
	nop ;2
	nop ;4
	rep #$20 ;7
	rep #$20 ;10
	lda.l $4214 ;$4214-$4215 = 16-bit quotient from division, read on 16th cycle
	sta.b tcc__r0
	lda.l $4216 ;$4216-$4217 = 16-bit remainder after division
	sta.b tcc__r0h
	rtl

;signed int sdiv16by8(signed int num, signed char denom);
sdiv16by8:
	
	rtl

.ends
.base $00
