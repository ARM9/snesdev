
.macro LoadBlockToVRAM src, dest, size
	.a8
	.i16
	ldx #dest
	stx $2116			; $2116: Word address for accessing VRAM.
	lda #^src
	ldx #.loword(src)
	ldy #.loword(size)
	jsr DMAToVRAM
.endmacro

.macro FillVRAM src, dest, size
	.a8
	.i16
	ldx #dest
	stx $2116 ; destination address in vram
	lda #^src
	ldx #.loword(src)
	ldy #.loword(size)
	jsr DMAFixedToVRAM
.endmacro

.macro LoadPalette src, dest, size
	.a8
	.i16
	lda #<dest
	sta $2121
	lda #^src
	ldx #.loword(src)
	ldy #.loword(size)
	jsr DMAToCGRAM
.endmacro

.code

DMAToCGRAM:
	.a8
	.i16
	stx $4302
	sta $4304
	sty $4305
	
	ldx #$2200
	stx $4300	; Set DMA mode to byte, normal increment
	lda #$01
	sta $420B
	
	rts

DMAToVRAM:
	stx $4302	;data address
	sta $4304	;data bank
	sty $4305	;size of data
	
	lda #$80
    sta $2115
	
	ldx #$1801
	stx $4300   ; Set DMA mode to word, normal increment, destination to $2118
	
	lda #$01
	sta $420B
	
	rts

DMAFixedToVRAM:
	stx $4302 ; source address
	sta $4304 ; source bank
	sty $4305 ; transfer $10000 bytes
	
	lda #$80
	sta $2115 ; increment vram address on writes to $2119
	
	ldx #$1809 ; alternate byte writes to $2118/$2119 fixed source
	stx $4300
	
	lda #$01
	sta $420B
	
	rts
