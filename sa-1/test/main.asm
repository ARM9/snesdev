
    arch snes.cpu

;- Includes -------------------------------------

.include "header.inc"

.include "snes_regs_sa1.asm"

.include "timing.inc"

.include "mem.asm"
.include "ppu.asm"
.include "rotate.asm"
.include "interrupts.asm"

.include "sa1/sa1-main.asm"

.define SPC_BINARY "spc/tunes/ct-theme.spc"
.include "spc/spc_upload.asm"
;------------------------------------------------
.include "zpvars.asm"

.bss
	
.segment "PRGRAM"
	WRAM_Prg: .res $8000

.code
.global tstcall, tstcall2

.proc tstcall
	mem 8
	idx 16
	lda #5
	ldx #$42
	rtl
.endproc
.proc tstcall2
	mem 16
	idx 8
	ldx #$42
	lda #15
	rts
.endproc

_Reset:
	sei
	clc
	xce

	phk
	plb

	jml _InitSNES
; Program entry point after basic hardware initialization is done.
Entry:
	repp #$10
	sepp #$20
	
	lcall tstcall
	repp #$20
	sepp #$10
	call tstcall2
	
	rep #$10
	sep #$20
	
	lda #$00
	jsl LoadSPC
	
	jsl SetupInterrupts
	
	LoadBlockToWRAM $008000, WRAM_Prg, $8000
	LoadBlockToWRAM egg, $403000, egg_size
	phk
	plb
	jml .loword(WRAM_Main)|$7E0000
	
	
WRAM_Main:
	
	sep #$20
	lda #$80
	sta $2200 ; boot SA-1, enable IRQ
	
	;LoadBlockToVRAM bg2, $5A00, bg2_size
	
	LoadPalette lake_pal, 0, lake_pal_size
	LoadBlockToVRAM	lake, $5000, lake_size
	
	sta $2105
	sta $212C
	lda #$72
	sta $2107
	lda #$05
	sta $210B
	
	lda #$01
	sta $2105
	sta $212C
	
	lda #$0F
	WaitForHblank
	sta $2100
	;cli
@forever:
	wai
	bra @forever

