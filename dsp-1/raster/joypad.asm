.include "hdr.asm"

.ramsection "libsfc joypad variables" bank $7E slot 2
__num_joypads dsb 1
__pads_held dsb 0
__pads1_held dsb 2
__pads2_held dsb 2
__pads3_held dsb 2
__pads4_held dsb 2

__pads_prev dsb 0
__pads1_prev dsb 2
__pads2_prev dsb 2
__pads3_prev dsb 2
__pads4_prev dsb 2

__pads_down dsb 0
__pads1_down dsb 2
__pads2_down dsb 2
__pads3_down dsb 2
__pads4_down dsb 2

__pads_released dsb 0
__pads1_released dsb 2
__pads2_released dsb 2
__pads3_released dsb 2
__pads4_released dsb 2

.ends

;.define _B_A		$80
;.define _B_X		$40
;.define _B_L		$20
;.define _B_R		$10

;.define _B_B		$80
;.define _B_Y		$40
;.define _B_SELECT	$20
;.define _B_START	$10
;.define _B_UP		$08
;.define _B_DOWN		$04
;.define _B_LEFT		$02
;.define _B_RIGHT	$01

.macro _macro_readJoypad ;ARGS padnum, held, prev, down
	lda.l \2 ; held
	sta.l \3 ; prev
	lda.w $4218+(\1*2)
	sta.l \2 ; held
	eor.l \3 ; prev
	and.l \2 ; held
	sta.l \4 ; down
	jmp _fast_return_readJoypads_jumptable
.endm

.base $80
.section "libsfc_joypad_assembly_code" superfree

;uint8_t num_pads
initJoypads:
	sep #$20
	lda 4,s
	sta.w __num_joypads
	lda #$00
	sta.l $004016 ; not sure what this was for
	rep #$20
	rtl

;uint16_t joypadPressed(uint8_t pad);
;assume accumulator is 16 bits because tcc
joypadPressed:
	lda 4,s
	and.w #$000F
	;bmi +
	asl
	tax
	
	lda.w __pads_down,x
	sta.b tcc__r0
	;plp
	rtl
;+	stz.b tcc__r0
;	rtl
;uint16_t joypadHeld(uint8_t pad);
joypadHeld:
	lda 4,s
	and.w #$000F
	;dec a
;	bmi +
	asl
	tax
	
	lda.w __pads_held,x
	sta.b tcc__r0
	rtl
;+	stz.b tcc__r0
;	rtl

_readJoypads_jumptable:
.dw _readJoypad1
.dw _readJoypad2
.dw _readJoypad3
.dw _readJoypad4
;.dw _readJoypad5
;.dw _readJoypad6
;.dw _readJoypad7
;.dw _readJoypad8

;
_libsfc_readJoypads:
	;pha ;+2
	;php ;+1 ; stack: 2
	phb
	
	phk
	plb
	rep #$30
	lda.l __num_joypads
	and #$000F
	beq +
	dea
	asl
	tax
	
	;sep #$20
	lda #$01
-	bit $4212
	bne -
_jump_to_next_readJoypad:
	;sep #$20
	jmp (_readJoypads_jumptable,x)
_fast_return_readJoypads_jumptable:
	dex
	dex
	bpl _jump_to_next_readJoypad
	rep #$20
+	plb
	;plp
	rtl

_readJoypad1:
	_macro_readJoypad 0, __pads1_held, __pads1_prev, __pads1_down;ARGS padnum, held, prev, down

_readJoypad2:
	_macro_readJoypad 1, __pads2_held, __pads2_prev, __pads2_down;ARGS padnum, held, prev, down

_readJoypad3:
	_macro_readJoypad 2, __pads3_held, __pads3_prev, __pads3_down;ARGS padnum, held, prev, down

_readJoypad4:
	_macro_readJoypad 3, __pads4_held, __pads4_prev, __pads4_down;ARGS padnum, held, prev, down

.ends
.base $00

