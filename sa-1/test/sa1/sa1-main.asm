
	.export sa1_Reset

	.code;.segment "BANK2"
sa1_Reset:
	clc
	xce
	rep #$39
	ldx #$1FFF
	txs
	
	jml sa1_entry
.segment "BANK2"
sa1_Entry:
	phk
	plb
	
	lda #$0000
	tcd

:	wai
	bra :-

