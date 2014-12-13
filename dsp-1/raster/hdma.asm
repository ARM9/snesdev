
macro _hdma_setup(channel) {
	lda.b #{channel}
    tsb.w _WRAM_HDMAEN
}

setupHDMAChannel0: // 16 bit X = $AABB AA = destination register BB = mode , 16 bit Y = $AABB source address high and low bytes,  8 bit A = source bank
	stx.w $4310 // mode
	//	$4311 = destination register
	sty.w $4312 // low byte
	//	$4313 = high byte
	sta.w $4314
	
	_hdma_setup($01)
	rts

setupHDMAChannel1: // 16 bit X = $AABB AA = destination register BB = mode , 16 bit Y = $AABB source address high and low bytes,  8 bit A = source bank
	stx.w $4310 // mode
	//	$4311 = destination register
	sty.w $4312 // low byte
	//	$4313 = high byte
	sta.w $4314
	
	_hdma_setup($02)
	rts

setupHDMAChannel2:
	stx.w $4320 // mode
	//	$4311 = destination register
	sty.w $4322 // low byte
	//	$4313 = high byte
	sta.w $4324
	
	_hdma_setup($04)
	rts

setupHDMAChannel3: // 16 bit X = $AABB AA = destination register BB = mode , 16 bit Y = $AABB source address high and low bytes,  8 bit A = source bank
	stx.w $4330 // mode
	//	$4311 = destination register
	sty.w $4332 // low byte
	//	$4313 = high byte
	sta.w $4334
	
	_hdma_setup($08)
	rts

setupHDMAChannel4:
	stx.w $4340 // mode
	//	$4311 = destination register
	sty.w $4342 // low byte
	//	$4313 = high byte
	sta.w $4344
	
	_hdma_setup($10)
	rts
	
setupHDMAChannel5:
	stx.w $4350 // mode
	//	$4311 = destination register
	sty.w $4352 // low byte
	//	$4313 = high byte
	sta.w $4354
	
	_hdma_setup($20)
	rts

setupHDMAChannel6:
	stx.w $4360 // mode
	//	$4311 = destination register
	sty.w $4362 // low byte
	//	$4313 = high byte
	sta.w $4364
	
	_hdma_setup($40)
	rts
	
setupHDMAChannel7:
	stx.w $4370 // mode
	//	$4311 = destination register
	sty.w $4372 // low byte
	//	$4313 = high byte
	sta.w $4374
	
	_hdma_setup($80)
	rts

// vim:ft=bass
