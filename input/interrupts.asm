
.macro WaitForHblank
	.a8
	.local L0 ; nameless labels in macros are dangerous
L0:	lda f:REG_HVBJOY
	bit #$40
	beq L0
.endmacro

.macro WaitForGSUStop
	.a8
	.local L0
L0:	lda f:GSU_SFR
	and #$20
	beq L0
.endmacro

.macro VSync
	.local L0, L1
L0:	lda REG_HVBJOY
	bpl L0
L1:	lda REG_HVBJOY
	bmi L1
.endmacro


.code
.scope Interrupts
Init:
	.a8
	.i16
	lda #$81	; HV-IRQ and autojoy enabled
	sta REG_NMITIMEN
	rts
.endscope

nmiHandler:
	rep #$30
	pha
	phx
	phy
	phb
	
	sep #$20
	inc frame_counter
	
	lda #$00
	pha
	plb
	
	lda f:Text::dirty
	beq :+
	jsr dmaTextBufferToVRAM
:
	rep #$30
	plb
	ply
	plx
	pla
	rti

irqHandler:
	
	rti

irqWRAM:
	rep #$30
	pha
	lda f:REG_RDNMI ; read both nmi and irq flag
	bmi :+ ; See if IRQ was triggered by console
	lda f:GSU_SFR ; else clear gsu irq and do nothing in particular
	pla
	rtl
	
:	sei
	phb
	phx
	phy
	
	sep #$20
	lda #$00
	pha
	plb
	
	rep #$30
	ply
	plx
	plb
	pla
	rtl


.segment "BANK2"
;Interrupt vectors to be executed during 65816 operation in WRAM
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
	jsl $7E0000|.loword(irqWRAM)
	rti
:	.word 0;jsl $7E0000|.loword(nmiHandler)	;nmi goes here
	rti
DummyVectorsSize = * - DummyVectors

