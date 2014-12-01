; SNES SPC loader
; /Mic, 2010
; Modified for ca65 by ARM9
; Based on code by Joe Lee


 ; The starting SNES ROM bank of the 64kB SPC RAM dump
SPC_DATA_BANK = 6
 ; The base address of the SNES ROM chunk containing DSP and SPC register values
;SPC_REG_ADDR = $58000
 
 ; The initialization code will be written to this address in SPC RAM if no better location is found
SPC_DEFAULT_INIT_ADDRESS = $ff70
 
 ; The length of our init routine in bytes
SPC_INIT_CODE_LENGTH = $2b 
 
 ; The length of our fastloader routine in bytes
SPC_FASL_LENGTH = $32


; Zero page variables
spcSongNr = $00
spcMirrorVal = $01
spcSourceAddr = $02	; Three bytes!
spcExecAddr = $05	; Two bytes!
spcScanVal = $07
spcScanLen = $08
spcFree00 = $09	; Two bytes!
spcFreeFF = $0b	; Two bytes!
spcFound00 = $0d
spcFoundFF = $0e

.define A_8BIT $20
.define XY_8BIT $10

.macro sendMusicBlockM srcSeg, srcAddr, destAddr, len
	; Store the source address \1:\2 in musicSourceAddr.
	sep     #A_8BIT
	lda     #srcSeg
	sta     spcSourceAddr + 2
	rep     #A_8BIT
	lda     #srcAddr
	sta     spcSourceAddr

	; Store the destination address in x.
	; Store the length in y.
	rep     #XY_8BIT
	ldx     #destAddr
	ldy     #len
	jsr     CopyBlockToSPC
.endmacro
 
.macro startSPCExecM startAddr
	rep     #XY_8BIT
	ldx     #startAddr
	jsr     StartSPCExec
.endmacro


.macro waitForAudio0M
 	sta	spcMirrorVal
:	cmp REG_APUIO0
 	bne :-
.endmacro


.segment "BANK1"

LoadSPC:
	phb
	php
	; Make sure NMI and IRQ are off
	stz     REG_NMITIMEN 
	sei
	
	sta	spcSongNr
	
	; Make sure echo is off
	sep	#A_8BIT
	lda	#$7d		; Register $7d (EDL)
	sta	$7f0100
	lda	#$00		
	sta	$7f0101
	sendMusicBlockM $7f, $0100, $00f2, $0002 	
	sep	#A_8BIT
	lda	#$6c		; Register $6c (FLG)
	sta	$7f0100
	lda	#$20		; Bit 5 on (~ECEN)	
	sta	$7f0101
	sendMusicBlockM $7f, $0100, $00f2, $0002
	
	; Initialize DSP registers, except FLG, EDL, KON and KOF
	jsr     InitDSP
	
	; Copy the SPC RAM dump to SNES RAM
	jsr     CopySPCMemoryToRam
	
	; Now we try to find a good place to inject our init code on the SPC side
 	;=======================================================================
 	rep	#XY_8BIT
 	ldx	#SPC_DEFAULT_INIT_ADDRESS
 	stx	spcExecAddr
 	
 	; Check if we've got a non-zero EDL. In that case we use ESA*$100 + $200 as the base
 	; address for our init code.
 	sep	#A_8BIT
 	lda	f:dsp_reg_data+$7d	; EDL
 	beq	:+			
 	lda	f:dsp_reg_data+$6d	; ESA
	clc
	adc	#2
 	xba
 	lda	#0
 	rep	#A_8BIT
 	tax				; X = ESA*$100 + $200
 	stx	spcExecAddr
 	jmp	addr_search_done
:
 	
 	; Search for a free chunk of RAM somewhere in the range $0100..$ff9f
 	; A free chunk is defined as a string of adequate length that contains
 	; only the value $00 or $ff (i.e. either 00000000.. or FFFFFFFF..).
 	; Strings containing $ff are preferred, so if such a string is found
 	; the search will terminate and the address of that string will be used.
 	; If a string containing $00 is found first, the search will continue
 	; until a string containing $ff is found, or until we've reached then
 	; end address ($ff9f).
 	sep	#A_8BIT
 	stz	spcFound00
 	stz	spcFoundFF
 	ldx	#0
 	stx	spcFree00
 	stx	spcFreeFF
 	ldx	#$100
 	search_free_ram:
		cpx	#$ff9f
		bcs	pick_best_address	; Found no free RAM. Give up and use the default address
		lda	#0
		sta	spcScanLen	
		search_free_ram_inner:
			lda	$7f0000,x	; Read one byte from RAM
			xba			; Save it in the high byte of A
			lda	spcScanLen	; Is this a new string, or one we've already begun matching?
			beq	search_free_ram_new_string
			xba
			cmp	spcScanVal	; Compare with the current value we're scanning for
			bne	scan_next_row	; No match?
			inc	spcScanLen
			lda	spcScanLen
			cmp	#($0C+SPC_INIT_CODE_LENGTH)
			beq	found_free_ram
			inx
			bra	search_free_ram_inner
			scan_next_row:		; Move to the next row, i.e. (16 - (current_offset % 16)) bytes ahead. 
			rep	#A_8BIT
			txa
			clc
			adc	#$0010
			and	#$FFF0
			tax
			sep	#A_8BIT
			jmp	search_free_ram	; Gotta keep searchin' searchin'..
			search_free_ram_new_string:
			xba			; Restore the value we read from RAM
			cmp	#$00
			beq	search_free_ram_new_string00
			cmp	#$ff
			beq	search_free_ram_new_stringFF
			bra	scan_next_row	; Neither $00 or $ff. Try the next row
			search_free_ram_new_string00:
			lda	spcFound00	
			bne	scan_next_row	; We've already found a 00-string
			stz	spcScanVal
			bra	:+
			search_free_ram_new_stringFF:
			lda	spcFoundFF
			bne	scan_next_row	; We've already found an FF-string
			lda	#$ff
			sta	spcScanVal
:
			inc	spcScanLen
			inx
			jmp	search_free_ram_inner	
	found_free_ram:
	rep	#A_8BIT
	txa
	sec
	sbc	#($0B+SPC_INIT_CODE_LENGTH)
	tax
	sep	#A_8BIT
	lda	spcScanVal
	bne	found_stringFF	
	stx	spcFree00			; This was a 00-string that we found
	lda	#1
	sta	spcFound00
	jmp	search_free_ram			; Find a place to hide, searchin' searchin'..
	found_stringFF:
	stx	spcFreeFF			; This was an FF-string that we found
	lda	#1
	sta	spcFoundFF
	
	pick_best_address:
	lda	spcFoundFF			; Prefer the FF-string if we've found one
	beq	:+
	ldx	spcFreeFF
	stx	spcExecAddr
	bra	addr_search_done
:
	lda	spcFound00
	beq	addr_search_done
	ldx	spcFree00
	stx	spcExecAddr
	
  	addr_search_done:
  	;=======================================================================
  	
	; Copy fastloader to SNES RAM
	rep	#XY_8BIT
	sep	#A_8BIT
	ldx	#(SPC_FASL_LENGTH-2)
:
		lda	f:spc700_fasl_code,x
		sta	$7f0000,x
		dex
		bpl	:-
	; Modify some values/addresses in the fastloader	
	lda   f:dsp_reg_data+$5c	; DSP KOF
	sta	$7f000b
	lda   f:dsp_reg_data+$4c	; DSP KON
	sta	$7f002d
	lda	spcExecAddr
	sta	$7f0030
	lda	spcExecAddr+1
	sta	$7f0031
	
	; Send the fastloader to SPC RAM
	sendMusicBlockM $7f, $0000, $0002, SPC_FASL_LENGTH
	
	; Start executing the fastloader
	startSPCExecM $0002
	
  	; Build code to initialize registers.
	jsr     MakeSPCInitCode

	; Upload the SPC data to $00f8..$ffff
	sep	#A_8BIT
	ldx	#$00f8
  	send_by_fasl:
		lda	$7f0000,x
		sta	REG_APUIO1
		lda	$7f0001,x
		sta	REG_APUIO2
		txa
		sta	REG_APUIO0
		waitForAudio0M
		inx
		inx
		bne	send_by_fasl
	
	; > The SPC should be executing our initialization code now <

 	phb			; Save DBR
 	lda 	spcSongNr
 	asl	a
 	clc
 	adc	#SPC_DATA_BANK
 	pha
 	plb		
	ldx	#0
	copy_spc_page0:
		lda	$8000,x	; Read from ROM
		sta	REG_APUIO1
		txa
		sta	REG_APUIO0
		waitForAudio0M
		inx
		cpx	#$f0
		bne	copy_spc_page0
	; Send the init value for SPC registers $f0 and $f1
	lda	#$0a
	sta	REG_APUIO1
	lda	#$f0
	sta	REG_APUIO0
	waitForAudio0M
	lda	$80f1
	and	#7		; Mask out everything except the timer enable bits
	sta	REG_APUIO1
	lda	#$f1
	sta	REG_APUIO0
	waitForAudio0M
	plb			; Restore DBR
	
	; Write the init values for the SPC I/O ports
	lda	$7f00f7
	sta	REG_APUIO3
	lda	$7f00f6
	sta	REG_APUIO2
	lda	$7f00f4
	sta	REG_APUIO0
	lda	$7f00f5
	sta	REG_APUIO1
	
	plp
	plb
 	rtl



CopySPCMemoryToRam:
 	; Copy music data from ROM to RAM, from the end backwards.
 	rep	#XY_8BIT        ; xy in 16-bit mode.
 	sep	#A_8BIT
 	ldx 	#$7fff          ; Set counter to 32k-1.
 
 	phb			; Save DBR
 	lda 	spcSongNr
 	asl	a
 	clc
 	adc	#SPC_DATA_BANK
 	pha
 	plb			; Set DBR to spcSongNr*2 + SPC_DATA_BANK
:  	lda 	$8000,x     	; Copy byte from first music bank.
 	sta 	$7f0000,x
 	dex
 	bpl 	:-
 
 	lda	spcSongNr
 	asl	a
 	clc
 	adc	#(SPC_DATA_BANK+1)
 	pha
 	plb			; Set DBR to spcSongNr*2 + SPC_DATA_BANK + 1
 	ldx 	#$7fff          ; Set counter to 32k-1.
:
 	lda 	$8000,x     	; Copy byte from second music bank.
 	sta 	$7f8000,x
 	dex
 	bpl 	:-
 	
 	plb			; restore DBR
 
	rts


; Loads the DSP init values in reverse order
 InitDSP:
	rep     #XY_8BIT	; xy in 16-bit mode
	lda	spcSongNr

	rep	#A_8BIT		; 16-bit accum
	xba
	lda	#0		; Clear high byte
	xba
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	#$007F
	tax			; x = spcSongNr*128 + 127
	sep	#A_8BIT		; 8-bit accum
	
	ldy	#$007F		; Reset DSP address counter.
:
	sep     #A_8BIT
	tya                   	; Write DSP address register byte.
	sta     $7f0100            
	lda   f:dsp_reg_data,x     	
	sta     $7f0101         ; Write DSP data register byte.    
	phx                   	; Save x on the stack.
	phy

	cpy	#$006c
	beq	skip_dsp_write
	cpy	#$007d
	beq	skip_dsp_write
	cpy	#$004c
	beq	skip_dsp_write
	cpy	#$005c
	bne	:+
	lda	#$ff
	sta	$7f0101
:
	
	; Send the address and data bytes to the DSP memory-mapped registers.
	sendMusicBlockM $7f, $0100, $00f2, $0002

	skip_dsp_write:
	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
	rep     #XY_8BIT            ; Restore x.
	ply
	plx

	; Loop if we haven't done 128 registers yet.
	dex
	dey
	cpy     #$FFFF
	bne     :--
	rts
	

 MakeSPCInitCode:
     ; Constructs SPC700 code to restore the remaining SPC state and start
     ; execution.
 
  	rep     #A_8BIT
 	lda	#0
 	ldx	#0			; Make sure A and X are both clear
 	rep	#XY_8BIT

  	ldy	spcExecAddr		; The address in SPC RAM that we're going
  					; to copy the init routine to (the same address
  					; is used in SNES RAM).
 	
	sep     #A_8BIT

	lda	spcSongNr
	asl	a
	asl	a
	asl	a
	tax				; x = spcSongNr * 8

	phb				; Save DBR
	lda	#$7f
	pha
	plb				; Set DBR=$7f (RAM)
	
	phx				; Save X
	ldx	#0
:
	lda	f:spc700_init_code,x
	sta	$0000,y			; Store in SNES RAM
	iny
	inx
	cpx	#SPC_INIT_CODE_LENGTH
	bne	:-
	plx				; Restore X

	ldy	spcExecAddr
	
	; Patch the init routine with the correct register values etc. for this song
	lda   f:SPC_REG_ADDR+6,x	; SP
	sta	$0001,y
	lda   f:SPC_REG_ADDR+5,x	; PSW
	sta	$0004,y
	lda   f:dsp_reg_data+$7d	; EDL
	sta	$0019,y
	lda   f:SPC_REG_ADDR+2,x 	; A
	sta	$001c,y
	lda   f:SPC_REG_ADDR+3,x 	; X
	sta	$001e,y
	lda   f:SPC_REG_ADDR+4,x 	; Y
	sta	$0020,y
	lda   f:dsp_reg_data+$6c	; FLG
	sta   $0025,y
	rep     #A_8BIT
	lda   f:SPC_REG_ADDR,x  	; PC
	sta	$0029,y
	sep	#A_8BIT
	
	plb				; Restore DBR
	rts


; spcSourceAddr - source address
; x - dest address
; y - count
 CopyBlockToSPC:
 	rep	#XY_8BIT
 	
	; Wait until audio0 is $aa
	sep     #A_8BIT
	lda     #$aa
	waitForAudio0M

	stx     REG_APUIO2		; Write it to APU Port2 as well
	
	; Transfer count to x.
	phy
	plx

 	; Send $01cc to AUDIO0 and wait for echo.
	lda	#$01
	sta     REG_APUIO1
	lda	#$cc
	sta     REG_APUIO0
	waitForAudio0M

	sep     #A_8BIT

	; Zero counter.
	ldy     #$0000
 CopyBlockToSPC_loop:
	lda     [spcSourceAddr],y

	sta	REG_APUIO1
	
	; Counter -> A
	tya

	sta	REG_APUIO0

	; Wait for counter to echo back.
	waitForAudio0M

	; Update counter and number of bytes left to send.
	iny
	dex
	bne     CopyBlockToSPC_loop

 	sep	#A_8BIT
 	
	; Send the start of IPL ROM send routine as starting address.
	ldx     #$ffc9
	stx     REG_APUIO2
	
	; Tell the SPC we're done transfering for now
	lda     #0
	sta	REG_APUIO1
	lda	spcMirrorVal	; This value is filled out by waitForAudio0M
	clc
	adc	#$02		
	sta	REG_APUIO0

	; Wait for counter to echo back.
	waitForAudio0M

	rep     #A_8BIT
	
	rts

 
 
; Starting address is in x.
 StartSPCExec:
	; Wait until audio0 is $aa
	sep     #A_8BIT
	lda     #$aa
	waitForAudio0M

	; Send the destination address to AUDIO2.
	stx     REG_APUIO2

	; Send $00cc to AUDIO0 and wait for echo.
	lda     #$00
	sta     REG_APUIO1
	lda     #$cc
	sta     REG_APUIO0
	waitForAudio0M

	rts

.segment "BANK3"
spc700_init_code:
 .byte $cd, $00		; mov 	x,#$xx		(the value is filled in later)
 .byte $bd		; mov	sp,x
 .byte $cd, $00		; mov 	x,#$xx		(the value is filled in later)
 .byte $4d		; push	x
 .byte $cd, $00		; mov   x,#0
 .byte $3e, $f4  		; -: cmp   x,$f4
 .byte $d0, $fc 		;    bne   -
 .byte $e4, $f5  		;    mov   a,$f5
 .byte $d8, $f4  		;    mov   $f4,x
 .byte $af 		;    mov   (x)+,a
 .byte $c8, $f2		;    cmp   x,#$f2
 .byte $d0, $f3		;    bne   -
 .byte $8f, $7d, $f2	; mov	$f2,#$7d
 .byte $8f, $00, $f3	; mov	$f3,#$xx	(the value is filled in later)
 .byte $e8, $00		; mov	a,#$xx		(the value is filled in later)
 .byte $cd, $00		; mov	x,#$xx		(the value is filled in later)
 .byte $8d, $00		; mov	y,#$xx		(the value is filled in later)
 .byte $8f, $6c, $f2	; mov	$f2,#$6c
 .byte $8f, $00, $f3	; mov	$f3,#$xx	(the value is filled in later)
 .byte $8e		; pop	psw
 .byte $5f, $00, $00	; jmp	$xxxx		(the address is filled in later)
 ; 43 bytes
 ; minimum 22 cycles per byte transfered


; Code for transferring data to SPC RAM at $00f8..$ffff
spc700_fasl_code:
 .byte $cd, $00		; 0002 mov x,#0
 .byte $8d, $f8		; 0004 mov y,#$f8
 .byte $8f, $00, $f1	; 0006 mov $f1, #0
 .byte $8f, $5c, $f2	; 0009 mov $f2, #$5c 
 .byte $8f, $00, $f3	; 000c mov $f2, #$xx  	(the value is filled in later)
 .byte $7e, $f4     	; 000f -: cmp   y,$f4  
 .byte $d0, $fc     	; 0011    bne   -
 .byte $e4, $f5     	; 0013    mov   a,$f5
 .byte $d6, $00, $00	; 0015    mov   $0000+y,a
 .byte $cb, $f4     	; 0018    mov   $f4,y
 .byte $e4, $f6     	; 001a    mov   a,$f6
 .byte $d6, $01, $00     	; 001c    mov   $0001+y,a
 .byte $fc        	; 001f    inc   y
 .byte $fc        	; 0020    inc   y
 .byte $d0, $ec     	; 0021    bne   - 
 .byte $ac, $17, $00     	; 0023    inc   $0017
 .byte $ac, $1e, $00     	; 0026    inc   $001e
 .byte $d0, $e4		; 0029    bne   -
 .byte $8f, $4c, $f2	; 002b mov   $f2, #$4c 
 .byte $8f, $00, $f3	; 002e mov   $f2, #$xx 	(the value is filled in later)
 .byte $5f, $00, $00	; 0031 jmp   $xxxx   	(the address is filled in later)
 ; 50 bytes
 ; minimum 17.55 cycles per byte transfered
 

; SPC-700 register values
.segment "BANK3" : far
SPC_REG_ADDR:
spc_reg_data:
.incbin SPC_BINARY, $00025, $0008
dsp_reg_data:
.incbin SPC_BINARY, $10100, $0080

; The actual 64k SPC RAM dump
.segment "BANK6" : far
spc_bin_low32k:
.incbin SPC_BINARY, $0100, $8000

.segment "BANK7" : far
spc_bin_hi32k:
.incbin SPC_BINARY, $8100, $8000

