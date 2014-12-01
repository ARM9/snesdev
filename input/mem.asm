
; Block move macros
; Expects 16 bit A and X/Y
.macro BlockMoveP src, dest, size
	.a16
	.i16
	ldx #.loword(source) ; Source address
	ldy #.loword(dest) ; Destination address
	lda #(size-1) ; Block size
	mvp (^src), (^dest) ; mvp sourcebank, destinationbank
	;MVP Move Positive, some docs say destination > source (this seems to be incorrect? I guess it only applies to the low 16 bits of the address (in X and Y) and not the bank)
	; The MVP instruction uses the X and Y registers to denote the top address
	; of the two blocks of memory. The data is moved from the address in X to
	; the address in Y and then the XY and accumulator registers are
	; decremented until the accumulator underflows to $FFFF.
.endmacro

.macro BlockMoveN src, dest, size
	.a16
	.i16
	ldx #.loword(source) ; Source address
	ldy #.loword(dest) ; Destination address
	lda #(size-1) ; Block size
	mvn (^src), (^dest) ; MVN sourcebank, destinationbank
	;MVN Move Negative, destination < source
	; The MVN instruction uses the X and Y registers to denote the bottom (beginning)
	; address of the two memory segments to be moved. With MVN the data is moved
	; from the source in X to the destination in Y, then the X and Y registers are
	; incremented and the accumulator decremented until the accumulator
	; underflows to $FFFF.
.endmacro

; src = source far address
; dest = destination far address
; size = 0 - 64KB
; mode = What to put in $4300 
.macro DMA_WramSram src, dest, size, mode
	.a8
	.i16
	ldx #.loword(src)
	stx $2181
	lda #^src
	sta $2183
	
	ldx #.loword(dest)
	lda #<mode
	xba
	lda #^dest
	ldy #size
	jsr dma_wram_to_sram
.endmacro

.macro LoadBlockToWRAM src, dest, size
	.a8
	.i16
	ldx #.loword(dest)
	stx $2181
	lda #^dest
	sta $2183
	
	lda #^src
	ldx #.loword(src)
	ldy #size
	jsr dma_rom_to_wram
.endmacro

; Fill an area of WRAM with a const source from ROM
.macro FillWRAM src, dest, size
	.a8
	.i16
	ldx #.loword(dest)
	stx $2181		;set WRAM address to $7E0000
	lda #^dest
	sta $2183
	
	ldx #$8008
	stx $4300		;Set DMA mode to fixed source, byte to $2180
	
	lda #^src
	ldx #.loword(src)
	ldy #size
	jsr dma_rom_fixed_to_wram
.endmacro

.code

dma_rom_to_wram:
	.a8
	.i16
	stx $4302
	sta $4304
	sty $4305
	ldx #$8000
	stx $4300
	
	lda #$01
	sta $420B
	rts

dma_rom_fixed_to_wram:
	stx $4302
	sta $4304
	sty $4305

	lda #$01
	sta $420B
	rts

dma_wram_to_sram:
	.a8
	.i16
	stx $4302
	sta $4304
	sty $4305
	lda #$80
	xba
	tax
	stx $4300
	
	lda #$01
	sta $420B
	
	rts
