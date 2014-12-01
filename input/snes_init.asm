
.macro init_snes
	sei
	clc
	xce
	
	rep #$38
	
	jml clear_everything
.endmacro

.segment "BANK2"
clear_everything:
	.a16
	lda #$1FFF
	tcs
	
	lda #$0000
	tcd
	
	sep #$20
	
	phk
	plb
	
	lda #$80
	sta $2100	;Force blank
	
	xba
	ldx #$2101
:				;$2101-$210C
	sta $00,X
	inx
	cpx #$210D
	bne :-
	
:				;$210D-$2121
	sta $00,X
	sta $00,X
	inx
	cpx #$2121
	bne :-
	
	ldx #$2123
:				;$2123-$2133
	sta $00,X
	inx
	cpx #$2134
	bne :-
	
	;stz $213E ; wut?
	
	sta $4200	;$4200  - disable timers, NMI and auto-joy
	sta $4016
	
	lda #$FF
	sta $4201
	
	lda #$00
	ldx #$4207
:	sta $00,X
	inx
	cpx #$420E
	bne :-
	
	;lda $4210 ; Who did this and why? NMI is cleared on power/reset, interrupts are also disabled at this point.
	
;OAM
	sta $2102
	sta $2103
	ldx #$0080
	lda #$E0
	
:	sta $2104
	sta $2104
	stz $2104
	stz $2104
	dex
	bne :-
	
	ldx #$0020
:	stz $2104
	dex
	bne :-
;VRAM
	lda #$80
	sta $2115 ; increment vram address on writes to $2119
	ldx #$0000
	stx $2116 ; begin at address $0000 in vram
	stx $4305 ; transfer $10000 bytes
	ldx #.loword(CONST_ZERO)
	lda #^CONST_ZERO
	stx $4302 ; source address
	sta $4304 ; source bank
	
	ldx #$1809 ; alternate byte writes to $2118/$2119 fixed source
	stx $4300
	
	lda #$01
	sta $420B
	
;CGRAM
	stz $2121
	ldx #$200 ; 512 bytes
	stx $4305
	ldx #$2208 ; write a byte at a time to $2122 from fixed source
	stx $4300
	
	lda #$01
	sta $420B
	
;WRAM
	stz $2181		;set WRAM address to $7E0000
	stz $2182
	stz $2183
	
	ldx #$8008
	stx $4300		;Set DMA mode to fixed source, byte to $2180
	sta $420B		;Begin transfer
	;$2183 is incremented after 64KiB has been transfered
	nop
	sta $420B		;now set the next 64k
	
	;Clear the framebuffer
	;ldx #.loword(FRAMEBUFFER)
	;lda #^FRAMEBUFFER
	;ldy #FRAMEBUFFER_SIZE
	;ldx #$0000
	;lda #^FRAMEBUFFER
	;ldy #$0000
	;stx $4302
	;sta $4304
	;sty $4305
	;ldx #$8080
	;stx $4300
	;
	;lda #$01
	;sta $420B
	
	; Initialize GSU
	lda #$01
	sta GSU_CLSR
	lda #(GSU_CFGR_IRQ_MASK | GSU_CFGR_FASTMUL)
	sta GSU_CFGR
	lda #0
	sta GSU_SCBR
	
	stz GSU_RAMBR
	
	jml Entry

CONST_ZERO:
	.word $0000
