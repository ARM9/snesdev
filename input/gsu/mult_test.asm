
.include "casfx.inc"

.segment "BANK1"
mult_test:
	iwt R12, #275
	nop;cache
	move R13, R15
@lop:
	loop
	mult r0
	nop
	stop
	nop
