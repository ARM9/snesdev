; SNES SPC file player
; /Mic, 2010

.include "snes.inc"


 .define SPC_FILE "spctestset/ts-06.spc"
  
  
 ; ZP variables
 .define selection	 $00f0
 .define tileScrollY	 $00f1
 .define joy1HighMask	 $00f2
 .define joy1HighData	 $00f3
 .define vramAddr	 $00f4
 .define titleAddr	 $00f6
 .define putsColor	 $00f8
 
 

 .bank 0
 .section "MainCode"
 
 .include "loadspc.asm"
 
 Start:
	; Initialize the SNES.
	Snes_Init

	sep	#(A_8BIT|XY_8BIT)

	lda     #BLANK_SCREEN  	; Force VBlank by turning off the screen.
	sta     REG_DISPCNT

	; Load the first SPC
	lda 	#0
	jsr 	LoadSPC
	
	SetPalette palette,0,96
	LoadVRAM font,0,(font_end-font)

	; Set display mode 2 (all BG layers use 16-color tiles)
	lda	#1
	sta     REG_DISPMODE

	lda     #BG1_ENABLE
	sta     REG_BGCNT

	; Set the pattern base address for BG0 to $0000
	stz     REG_CHRBASE_L

	; Set the map base address for BG0 to $4000 and the map size to 32x32 tiles
	lda     #32
	sta     REG_BG1MAP

	sep	#A_8BIT
	stz	selection
	stz	tileScrollY
	stz	joy1HighMask

	; Clear BG0
	sep	#A_8BIT
	lda	#$00
	sta	REG_VRAM_ADDR_L
	lda	#$20
	sta	REG_VRAM_ADDR_H
	rep	#XY_8BIT
	ldx	#$400
 -:
 	stz	REG_VRAM_DATAW1
 	stz	REG_VRAM_DATAW2
	dex
 	bne	-
	sep	#XY_8BIT 	
	
	jsr	DrawScreen

	sep     #A_8BIT
	
	lda     #$0F  		; End VBlank, setting brightness to 15 (100%).
	sta     REG_DISPCNT

 	cli             ; Enable IRQ
 	sep     #A_8BIT ; Enable NMI
 	lda     #$81
 	sta     REG_NMI_TIMEN
 	
	; Loop forever.
Forever:

	jmp Forever
 
 
 DrawScreen:
 	rep	#(A_8BIT|XY_8BIT)
 	lda	#0
 	
 	sep	#A_8BIT

 	lda	#1
 	ldx	#songTitle
 	ldy	#$4044
 	jsr	Puts
 	lda	#2
 	ldx	#spcSongTitle
 	ldy	#$4054
 	jsr	Puts

 	lda	#1
 	ldx	#gameTitle
 	ldy	#$40c4
 	jsr	Puts
 	lda	#2
 	ldx	#spcGameTitle
 	ldy	#$40d4
 	jsr	Puts

  	lda	#1
 	ldx	#author
 	ldy	#$4144
 	jsr	Puts
 	lda	#2
 	ldx	#spcAuthor
 	ldy	#$4154
 	jsr	Puts
 	
 	LoadVRAM creditString,$4600,112 
 
 	rts
  

; a = palette
; x = source address
; y = dest address
Puts:
	rep	#XY_8BIT
	asl	a
	asl	a
	sta	putsColor
	rep	#A_8BIT
	tya
	lsr	a
	sep	#A_8BIT
	sta	REG_VRAM_ADDR_L	
	xba
	sta	REG_VRAM_ADDR_H	
	phy
	ldy	#20	
	-:
	lda.w	$0000,x
	beq	PutsDone
	sec
	sbc	#32
	sta	REG_VRAM_DATAW1
	lda	putsColor
	sta	REG_VRAM_DATAW2
	inx
	dey
	bne	-

	ply
	rep	#A_8BIT
	tya
	lsr	a
	clc
	adc	#$20
	sep	#A_8BIT
	sta	REG_VRAM_ADDR_L	
	xba
	sta	REG_VRAM_ADDR_H	
	phy
	ldy	#12	
	-:
	lda.w	$0000,x
	beq	PutsDone
	sec
	sbc	#32
	sta	REG_VRAM_DATAW1
	lda	putsColor
	sta	REG_VRAM_DATAW2
	inx
	dey
	bne	-
	
	PutsDone:
	ply
	rts
	

 ; Needed to satisfy interrupt definition in "Header.inc".
 VBlank:
 	php
 	pha
 	jsr	DrawScreen
 	stz	REG_VRAM_ADDR_L
 	stz	REG_VRAM_ADDR_H
 
   	pla
   	plp
   	rti


palette:
.dw $0000,$8010,$801F,$8018,0,0,0,0,0,0,0,0,0,0,0,0
.dw $0000,$8110,$811F,$8118,0,0,0,0,0,0,0,0,0,0,0,0
.dw $0000,$8310,$831F,$8318,0,0,0,0,0,0,0,0,0,0,0,0


creditString:
 .db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,51,0,48,0,35,0,0,0,48,0,76,0,65,0,89,0,69,0,82,0,0,0,86,0,17,0,14,0,19
 .db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,0,45,0,73,0,67
 .db 0,12,0,0,0,18,0,16,0,17,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


songTitle:
 .db "Title:",0
gameTitle:
 .db "Game:",0
author:
 .db "Author:",0
 
spcSongTitle:
 .incbin SPC_FILE skip $0002E read $0020
spcGameTitle:
 .incbin SPC_FILE skip $0004E read $0020
spcAuthor:
 .incbin SPC_FILE skip $000B1 read $0020


font: 
  .incbin "font.pat"
font_end:

.ends


; SPC-700 register values
.bank 1 slot 0
.org $0000
.incbin SPC_FILE skip $00025 read $0008
; DSP register values
.org $4000
.incbin SPC_FILE skip $10100 read $0080


; The actual 64k SPC RAM dump
.bank 2
.section "musicDataLow"
.incbin SPC_FILE skip $0100 read $8000
.ends
.bank 3
.section "musicDataHigh"
.incbin SPC_FILE skip $8100 read $8000
.ends



