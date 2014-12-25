
; 16 bit X = $AABB AA = destination register BB = mode , 16 bit Y = $AABB source address high and low bytes,  8 bit A = source bank
setupHDMAChannel1:
	stx $4310 ; mode
	;	$4311 = destination register
	sty $4312 ; low byte
	;	$4313 = high byte
	sta $4314
	
	lda #$02
	tsb !WR_HDMAEN
	rts

setupHDMAChannel2:
	stx $4320 ; mode
	;	$4311 = destination register
	sty $4322 ; low byte
	;	$4313 = high byte
	sta $4324
	
	lda #$04
	tsb !WR_HDMAEN
	rts

setupHDMAChannel3:
	stx $4330 ; mode
	;	$4311 = destination register
	sty $4332 ; low byte
	;	$4313 = high byte
	sta $4334
	
	lda #$08
	tsb !WR_HDMAEN
	rts

setupHDMAChannel4:
	stx $4340 ; mode
	;	$4311 = destination register
	sty $4342 ; low byte
	;	$4313 = high byte
	sta $4344
	
	lda #$10
	tsb !WR_HDMAEN
	rts

setupHDMAChannel5:
	stx $4350 ; mode
	;	$4311 = destination register
	sty $4352 ; low byte
	;	$4313 = high byte
	sta $4354
	
	lda #$20
	tsb !WR_HDMAEN
	rts

setupHDMAChannel6:
	stx $4360 ; mode
	;	$4311 = destination register
	sty $4362 ; low byte
	;	$4313 = high byte
	sta $4364
	
	lda #$40
	tsb !WR_HDMAEN
	rts

setupHDMAChannel7:
	stx $4370 ; mode
	;	$4311 = destination register
	sty $4372 ; low byte
	;	$4313 = high byte
	sta $4374
	
	lda #$80
	tsb !WR_HDMAEN
	rts


setupColorHDMA:

	ldx.w #$3202
	stx $4310
	ldx.w #RedGreenTable
	lda.b #RedGreenTable>>16
	stx $4312
	sta $4314
	
	ldx.w #$3200
	stx $4320
	ldx.w #BlueTable
	lda.b #BlueTable>>16
	stx $4322
	sta $4324
	
	rts