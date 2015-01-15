
//16-BIT MULTIPLICATION (DECIMAL, INTEGER)
// Name: Multiply
// Code: $00
// Parameters:
//	Input
//		K[T/I] Multiplicand
//		L[T/I] Multiplier
//	Output
//		M[T/H2] Product (rounded fraction <= 15 bits)
// 
// Function:
// This command determines the product, M, of decimal K and L.
// The command can also determine the product of integers [I],
// wherein the result of the calculation is a double precision half integer (H2).
// ARM9 note: ^ what does that even mean? How could the dsp-1 possibly distinguish between those, testing seems to indicate that it ALWAYS returns H2 (see Equation 5-1).
// Equation 5-1 (replaced with bsnes source for clarity, original just said M=K*L and the book never explains in a clear fashion that the DSP-1 uses a special format internally):
//	M = (K * L) >> 15
//
// Number of Process Cycles:
// 	Input
//		1. Command Input 6
//		2. K input 12
//		3. L input 4
//	Output
//		1. M output 4
//	Total: 26
// *Notes: 
//	1. Parameters are input/output via the DR register.
// 	2. Parameters are input/output in the order shown above.
//	The number of cycles is the period until the next parameter can
// 	be selected or the results of the calculation can be read.
//------------------------------------------------------------------

scope dspMult16: {
// returns:
//  x16 = (x16 * y16) >> 15
// args:
//	x16 = K
//  y16 = L
    //a8
    //i16
    php
    sep #$20
	lda.b #$00
	sta.w REG_DSP_DATA
	rep #$30
	stx.w REG_DSP_DATA // K
	sty.w REG_DSP_DATA // L
	ldx.w REG_DSP_DATA // M
    plp
	rts
}

// 5.1.2 INVERSE CALCULATION (FLOATING POINT)
// Name: Inverse
// Code: $10
// Parameters:
//	Input:
//		1. a[M] Coefficient
//		2. b[C] Exponent (8002-7FFFH)
//	Output:
//		1. A[M] Coefficient
//		2. 8[C] Exponent (8002-7FFFH)
// Function:
// This command determines the inverse of a floating point decimal number.
//
// Equation 5-2:
//	1/(a * 2^b) = A * 2^B
//
// Number of Process Cycles:
//	Input
//		1. Command Input 6
//		2. a input 13
//		3. b input 73
//	Output
//		1. A output 2
//		2. B output 4
//	Total: 98
//------------------------------------------------------------------
//void dspInverse(DSP_float *input)//
dspInverse:
	
	rts

// vim:ft=snes
