
; Supported control characters:
;	\n	= 0x0A

.segment "LORAM"
.scope Text
	WRAM_BUFFER_SIZE = $700
	dirty: .res 1
	wram_buffer: .res WRAM_BUFFER_SIZE ; Our map buffer, transfer during vblank
	wram_buffer_pointer: .res 2 ; internal buffer position pointer
.endscope

.code

.macro print buffer_ptr, x_pos, y_pos
	.a8
	.i16
	.if (.not .blank (x_pos)) && (.not .blank (y_pos) )
		rep #$30
		lda #((x_pos<<1)+(y_pos<<6))&$FFFE
		sta f:Text::wram_buffer_pointer
		sep #$20
	.endif
	lda #^buffer_ptr			; load bank byte of pointer
	ldx #.loword(buffer_ptr)	; load lower 16 bits of pointer
	jsr print_string
.endmacro

; itoa str_ptr, int
; str_ptr	= where to write the resulting zero-terminated string
; int		= immediate, register or address, passed in 16 bit accumulator
.macro itoa str_ptr, int
	.a16
	.i16
	.if( .not .blank(str_ptr) )
		.if( .not .blank(int) )
			.if( .xmatch({int}, {x}) )
			txa
			.elseif( .xmatch({int}, {y}) )
			tya
			.elseif( .xmatch({int}, {a}) )
			.else
			lda int
			.endif
		.endif
		ldx #.loword(str_ptr)
		ldy #^str_ptr
	.endif
	jsr int_to_string
.endmacro

print_string:
;args
; a		= pointer to text bank byte
; x		= pointer to text
;zeropage
; dp0 and dp1	= pointer to text for indirect long addressing
.a8
.i16
	phb
	php
	
	
	stx dp0
	sta dp1
	lda #^Text::wram_buffer
	pha
	plb
	rep #$20
	ldx .loword(Text::wram_buffer_pointer) ; Position in wram buffer
	ldy #$FFFF  ; Index for indirect indexed
@next_char:
	cpx #Text::WRAM_BUFFER_SIZE
	bcc :+ ; wrap buffer overflow
	ldx #0
:
	iny
	lda [dp0],y
	
	and #$00FF
	beq @end ; end on NULL
	
	cmp #$000A
	beq @line_feed
	
	;no control character
	sec
	sbc #32
	sta .loword(Text::wram_buffer),x
	inx
	inx
	bra @next_char
	
@line_feed: ; control character \n
	txa
	and #$FFC0
	clc
	adc #64
	tax
	bra @next_char
	
@end:
	stx .loword(Text::wram_buffer_pointer)
	
	plp
	inc a
	sta .loword(Text::dirty)
	plb
	rts

int_to_string: ;([accumulator]int n)
; Convert 16 bit integer to string
;args
; x		= pointer to string
; y		= bank byte of pointer to string
; a		= integer to convert
; dp0-1	= far pointer to string
.a16
.i16
	php
	
	stx dp0
	sty dp1
	
	tax
	ldy #$0004
	sep #$20
	lda #$00 ; terminate string
	sta [dp0],y
	dey
	
	txa
@next:
	and #$0F
	cmp #$0A
	bcs @is_hex
	adc #16+32
	bra :+
@is_hex:
	clc
	adc #23+32
:	sta [dp0],y
	rep #$20
	txa
	.repeat 4
	lsr
	.endrep
	tax
	sep #$20
	dey
	bpl @next
	
	plp
	rts

clearTextWramBuffer:
	lda #$00
	sta f:Text::wram_buffer_pointer
	sta f:Text::wram_buffer_pointer+1
	FillWRAM CONST_ZERO, Text::wram_buffer, Text::WRAM_BUFFER_SIZE
	rts

; Call during vblank
dmaTextBufferToVRAM:
	lda #$00
	sta f:Text::wram_buffer_pointer
	sta f:Text::wram_buffer_pointer+1
	LoadBlockToVRAM Text::wram_buffer, $7C00, Text::WRAM_BUFFER_SIZE
	rts


