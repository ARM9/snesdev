
.code

.macro CallGSU routine, prg_type
	.a8
	.i16
	lda #^routine
	ldx #.loword(routine)
	jsl WRAM_Prg|.loword(prg_type)
.endmacro


.a8
.i16
profile_gsu_program:
	php
	ldy #$0000
	sta GSU_PBR
	lda #(GSU_RON|GSU_RAN)
	sta GSU_SCMR
	lda #$20
	stx GSU_R15 ; Go
	
:	iny				; 8 cycles each iteration
	bit GSU_SFR		;
	beq :-			; last iteration 9 cycles because branch is skipped
	
	stz GSU_SCMR
	rep #$31
	tya
	sta dp0
	.repeat 7 ; multiply number of iterations by number of cycles (11)
	adc dp0
	clc
	.endrep
	adc dp0
	dec a ; -1 because last iteration takes 1 less cycle
	
	itoa performance_str, a; $9F4E
	sep #$20
	plp
	rtl

profile_gsu:
	sei
	stz $4200
	CallGSU mult_test, profile_gsu_program
	lda #$81
	sta $4200
	cli
	rts



