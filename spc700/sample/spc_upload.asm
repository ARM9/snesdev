// High-level interface to SPC-700 bootloader
//
// 1. Call spc.waitBoot
// 2. To upload data:
//   A. Call spc.beginUpload
//   B. Call spc.uploadByte any number of times
//   C. Go back to A to upload to different addr
// 3. To begin execution, call spc.execute
//
// Have your SPC code jump to $FFC0 to re-run bootloader.
// Be sure to call spc.waitBoot after that.


scope spc {
// Waits for SPC to finish booting. Call before first
// using SPC or after bootrom has been re-run.
// Preserved: X, Y
waitBoot:
    lda.b #$AA
-
    cmp.w REG_APUIO0
    bne -
    
    // Clear in case it already has $CC in it
    // (this actually occurred in testing)
    sta.w REG_APUIO0
    
    lda.b #$BB
-
    cmp.w REG_APUIO1
    bne -
    
    rts

// Starts upload to SPC addr Y and sets Y to
// 0 for use as index with spc.uploadByte.
// Preserved: X
beginUpload:
nextUpload: // deprecated
    sty.w REG_APUIO2
    
    // Send command
    lda.w REG_APUIO0
    clc
    adc.b #$22
    bne +  // special case fully verified
    inc
+
    sta.w REG_APUIO1
    sta.w REG_APUIO0
    
    // Wait for acknowledgement
-
    cmp.w REG_APUIO0
    bne -
    
    // Initialize index
    ldy.w #0
    
    rts


// Uploads byte A to SPC and increments Y. The low byte
// of Y must not be disturbed between bytes.
// Preserved: X
uploadByte:
    sta.w REG_APUIO1
    
    // Signal that it's ready
    tya
    sta.w REG_APUIO0
    iny
    
    // Wait for acknowledgement
-
    cmp.w REG_APUIO0
    bne -
    
    rts


// Starts executing at SPC addr Y
// Preserved: X, Y
execute:
    sty.w REG_APUIO2
    
    stz.w REG_APUIO1
    
    lda.w REG_APUIO0
    clc
    adc.b #$22
    sta.w REG_APUIO0
    
    // Wait for acknowledgement
-
    cmp.w REG_APUIO0
    bne -
    
    rts

// Uploads code from begin to begin+size to addr, and executes at addr
macro RunCode(addr, begin, size) {
    //a8
    //i16
    phb
    lda.b #{begin}>>16
    pha
    plb
    
    ldy.w #{addr}
    jsr spc.beginUpload

_loop{#}:
    lda {begin},y
    jsr spc.uploadByte
    cpy.w #{begin}+{size}
    bne _loop{#}
    
    ldy.w #{addr}
    jsr spc.execute
    
    plb
}
}

// vim:ft=snes
