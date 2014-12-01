
//LoadMode7Map 
//	requires: mem/A = 8 bit, X/Y = 16 bit
macro LoadMode7Map(SRC_ADDRESS, DEST, SIZE) {
	//Transfer map data to vram
	stz.w $2115	// increment vram address after write to $2118 (low byte)
    ldx.w #\2	// vram addr $0000
    stx.w $2116
    ldx.w #$1800	// Write to $2118
    stx.w $4300
	
    ldx.w #\1	// source address
	lda.b #:\1	// source bank
	ldy.w #\3	// # of bytes
	
	jsl start_dma_channel_0
}

//LoadMode7Tiles
//	requires: mem/A = 8 bit, X/Y = 16 bit
macro LoadMode7Tiles(SRC_ADDRESS, DEST, SIZE) {
	//Transfer tile data to vram
	lda.b #$80	// increment vram address after write to $2119 (high byte)
	sta.w $2115	
	ldx.w #\2	// vram addr
	stx.w $2116
	ldx.w #$1900// Write to $2119
	stx.w $4300
	
	ldx.w #\1	// source address
	lda.b #:\1	// source bank
	ldy.w #\3	// # of bytes
	
	jsl start_dma_channel_0
}

start_dma_channel_0:
    stx.w $4302
    sta.w $4304
    sty.w $4305
    
    lda.b #$01	// Enable DMA channel 0
    sta.w $420B
	rtl

dmaToVRAM:
	
dmaToVRAMLow:
	
dmaToVRAMHigh:
	
//void dmaToCGRAM(unsigned char dest, void *source, size_t size)//
dmaToCGRAM: //ASM optimized dma is faster than C macro dma
	lda.w #$2200
	sta.l $4300
	
	lda 10,s // size
	sta.l $4305 // Store size of data block
	lda 6,s // source address
	sta.l $4302 // Store data offset into DMA source offset
	
	sep #$20
	lda 4,s // start at dest color
    sta.l $2121
    lda 8,s // source bank
    sta.l $4304   // Store data bank into DMA source bank
	
    lda.b #$01    // Initiate DMA transfer
    sta.l $420B
	
	rep #$20
	rtl

//void dmaToWram(void **dest, void *source, size_t size, unsigned char mode)//
dmaToWram: // From A bus to WRAM, rom -> wram or sram -> wram for example. Source can NOT be in banks $7E/$7F.
	phb
	phk
	plb
	rep #$30
	lda.b 13,s // size_t size
	tay
	lda.b 9,s // void *source
	tax
	lda.b 5,s // void **dest
	sta.w $2181
	
	lda.w #$8000
	sep #$20
	ora.b 15,s // mode byte
	rep #$20
	sta.w $4300
	sep #$20
	
	lda.b 7,s// dest bank
	sta.w $2183
	
	lda.b 11,s // source bank
	stx.w $4302
	sta.w $4304
	sty.w $4305
	
	lda.b #$01
	sta.w $420B
	
	rep #$20
	plb //14 cycle overhead to swap from wram databank
	rtl

//void dmaFromWram(void **dest, void *source, size_t size, unsigned char mode)//
dmaFromWram: //You can only write to the A bus, wram -> sram for example.
	phb
	phk
	plb
	rep #$30
	lda.b 13,s // size_t size
	tay
	lda.b 5,s  // void *dest
	tax
	lda.b 9,s  // void **source
	sta.w $2181
	
	lda.w #$8080
	sep #$20
	ora.b 15,s // mode byte
	rep #$20
	sta.w $4300
	sep #$20
	
	lda.b 11,s // dest bank
	sta.w $2183
	
	lda.b 7,s  // source bank
	stx.w $4302
	sta.w $4304
	sty.w $4305
	
	lda.b #$01
	sta.w $420B
	
	rep #$20
	plb
	rtl

//enableBG:
//	sep #$20
//	lda 4,s
//	sta.l $00212C
//	rep #$20
//	rtl

makeMode7Game:
	php
	phb
	
	phk
	plb
	rep #$10
	sep #$20
	lda #$07
	sta $2105
	
	//LoadMode7Map koop_map, $0000, koop_map_end - koop_map
	//LoadMode7Tiles koop_tiles, $0000, koop_tiles_end - koop_tiles
	
	jsl _setupMatrixHDMA
	jsl _setupBGHDMA
	jsl _setupCamera
	
	plb
	plp
	rtl

// vim:ft=bass
