
	.include "ppu.asm"
	.code
SetupInterrupts:
	php
	rep #$30
	lda #.loword(WRAM_NMI_VECTOR)
	sta SA1_SNV
	lda #.loword(WRAM_IRQ_VECTOR)
	sta SA1_SIV
	;SA-1 vectors
	lda #.loword(sa1_reset)
	sta $2203
	lda #.loword(sa1_irqHandler)
	sta $2207
	
	sep #$20
	LoadBlockToWRAM DummyVectors, $7E00EC, DummyVectors_size
	lda #$81
	sta REG_NMITIMEN
	plp
	rtl

nmiHandler:
	rep #$30
	pha
	sep #$20
	lda f:REG_RDNMI
	
	LoadBlockToVRAM SUB_ROTATE::DestBWRAM, $0000, 512
	
	rep #$30
	pla
	rtl

irqHandler:
	rep #$30
	pha
	sep #$20
	lda f:REG_TIMEUP ; read both nmi and irq flag
	
	rep #$30
	pla
	rtl


	.segment "BANK1"

DummyVectors:
	nop	;cop
	nop
	nop	;brk
	nop
	stp ;abort
	nop
	bra :+ ;NMI
	;nop
	nop ;unused
	nop
	;IRQ
	jsl $7E0000|.loword(irqHandler)
	rti
:	jsl $7E0000|.loword(nmiHandler)	;nmi goes here
	rti
DummyVectors_size = * - DummyVectors

