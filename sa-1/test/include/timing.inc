
.macro WaitForHblank
	; Assumes 8 bit accumulator
:	bit REG_HVBJOY
	bvc :-
.endmacro

; TODO: Request feature that exposes current m/x flag, like * does for pc.
