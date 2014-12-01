
.define ROM_NAME "GSU unit test"
.include "header.inc"
.include "snes_regs.asm"
.include "snes_init.asm"
.include "zpvars.asm"
.include "assets.asm"

.include "ppu.asm"
.include "mem.asm"

.include "text.asm"

.include "interrupts.asm"
.include "gsu_comm.asm"

.segment "PRGRAM"
	WRAM_Prg: .res $8000

.rodata
my_string:
.byt "Some ", $0A, "t", $0A, "e", $0A, "x", $0A, "t", $0A, 0

long_string:
.byt "Here is some text hi more text more more need to fill the entire screen sheesh this is taking forever now this is a story all about how my life got flipped turned upside down and I'd like to take a minute just sit right there, I'll tell you how I became the prince of a town called bel air.", $A, "In west philadelphia born and raised on the playground is",$A,"where I spent most of my days chillin out maxin' relaxin' all cool and all shootin' some b-ball outside of a school when a couple of guys that were up to no good started making trouble in my neighbourhood I got in one little fight and my mom got scared and said you're moving with your auntie and uncle in bel air. aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa wrapped", 0

cycles_str:
.byt " Approx cycles: ", 0

.zeropage
	
.bss
	performance_str: .res 5
	parity: .res 1
	
.code
Reset:
	init_snes


Entry:
	rep #$10
	sep #$20
	lda #$ea
	sta parity
	
	LoadBlockToWRAM $8000, WRAM_Prg, $8000
	
	jsr Interrupts::Init
	jsr setupVideo
	
	print my_string
	print long_string
	
	;jsr clearTextWramBuffer
	
	lda #$0F
	sta $2100
	VSync
@forever:
	jsr profile_gsu
	print cycles_str, 1, 1
	print performance_str
	lda parity
	cmp #$ea
	beq :+
	jsl @forever
:	wai
	bra @forever


setupVideo:
	
	LoadBlockToVRAM torus_sans, $0000, torus_sans_size
	LoadPalette sfx_pal, $00, sfx_pal_size
	
	lda #$7C
	sta REG_BG1SC
	sta REG_BG2SC
	
	;lda #$00
	;sta REG_CGWSEL
	;lda #%00100011
	;sta REG_CGADSUB
	lda #$00
	sta REG_COLDATA
	
	lda #$00
	sta $2105
	lda #$03
	sta $212C
	
	lda #$FF
	sta REG_BG1VOFS
	stz REG_BG1VOFS
	;sta REG_BG1HOFS
	;stz REG_BG1HOFS
	
	dec a
	sta REG_BG2VOFS
	stz REG_BG2VOFS
	;sta REG_BG2HOFS
	;stz REG_BG2HOFS
	
	rts

; GSU code
.include "gsu/mult_test.asm"

