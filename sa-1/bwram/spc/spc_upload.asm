// SNES SPC loader
// /Mic, 2010
// Based on code by Joe Lee
// Modified for bass by ARM9
define SPC_BINARY("tunes/ct-theme.spc")

// The starting SNES ROM bank of the 64kB SPC RAM dump
constant SPC_DATA_BANK(spc_bin_low32k>>16)
 
// The initialization code will be written to this address in SPC RAM if no better location is found
constant SPC_DEFAULT_INIT_ADDRESS($ff70)
 
// The length of our init routine in bytes
constant SPC_INIT_CODE_LENGTH($2b) 
 
// The length of our fastloader routine in bytes
constant SPC_FASL_LENGTH($32)


// Zero page variables
constant spcSongNr($00)
constant spcMirrorVal($01)
constant spcSourceAddr($02) // Three bytes!
constant spcExecAddr($05)   // Two bytes!
constant spcScanVal($07)
constant spcScanLen($08)
constant spcFree00($09) // Two bytes!
constant spcFreeFF($0b) // Two bytes!
constant spcFound00($0d)
constant spcFoundFF($0e)

macro sendMusicBlockM(srcSeg, srcAddr, destAddr, len) {
    // Store the source address \1:\2 in musicSourceAddr.
    sep #$20
    lda.b #{srcSeg}
    sta.b spcSourceAddr + 2
    rep #$20
    lda.w #{srcAddr}
    sta.b spcSourceAddr

    // Store the destination address in x.
    // Store the length in y.
    rep #$10
    ldx.w #{destAddr}
    ldy.w #{len}
    jsr CopyBlockToSPC
}
 
macro startSPCExecM(startAddr) {
    rep #$10
    ldx.w #{startAddr}
    jsr StartSPCExec
}

macro scope waitForAudio0M() {
    sta.b spcMirrorVal
L{#}:
    cmp.w REG_APUIO0
    bne L{#}
}

    bank0()
LoadSPC:
    phb
    php
    // Make sure NMI and IRQ are off
    stz.w REG_NMITIMEN 
    sei
    
    sta.b spcSongNr
    
    // Make sure echo is off
    sep #$20
    lda #$7d        // Register $7d (EDL)
    sta $7f0100
    lda #$00        
    sta $7f0101
    sendMusicBlockM($7f, $0100, $00f2, $0002)
    sep #$20
    lda #$6c        // Register $6c (FLG)
    sta $7f0100
    lda #$20        // Bit 5 on (~ECEN) 
    sta $7f0101
    sendMusicBlockM($7f, $0100, $00f2, $0002)
    
    // Initialize DSP registers, except FLG, EDL, KON and KOF
    jsr InitDSP
    
    // Copy the SPC RAM dump to SNES RAM
    jsr CopySPCMemoryToRam
    
    // Now we try to find a good place to inject our init code on the SPC side
    //=======================================================================
    rep #$10
    ldx.w #SPC_DEFAULT_INIT_ADDRESS
    stx.b spcExecAddr
    
    // Check if we've got a non-zero EDL. In that case we use ESA*$100 + $200 as the base
    // address for our init code.
    sep #$20
    lda.l dsp_reg_data+$7d  // EDL
    beq +          
    lda.l dsp_reg_data+$6d  // ESA
    clc
    adc.b #2
    xba
    lda.b #0
    rep #$20
    tax             // X = ESA*$100 + $200
    stx.b spcExecAddr
    jmp _addr_search_done
+
    
    // Search for a free chunk of RAM somewhere in the range $0100..$ff9f
    // A free chunk is defined as a string of adequate length that contains
    // only the value $00 or $ff (i.e. either 00000000.. or FFFFFFFF..).
    // Strings containing $ff are preferred, so if such a string is found
    // the search will terminate and the address of that string will be used.
    // If a string containing $00 is found first, the search will continue
    // until a string containing $ff is found, or until we've reached then
    // end address ($ff9f).
    sep #$20
    stz.b spcFound00
    stz.b spcFoundFF
    ldx.w #0
    stx.b spcFree00
    stx.b spcFreeFF
    ldx.w #$100
    _search_free_ram:
        cpx.w #$ff9f
        bcs _pick_best_address   // Found no free RAM. Give up and use the default address
        lda.b #0
        sta.b spcScanLen  
        _search_free_ram_inner:
            lda $7f0000,x   // Read one byte from RAM
            xba             // Save it in the high byte of A
            lda.b spcScanLen  // Is this a new string, or one we've already begun matching?
            beq _search_free_ram_new_string
            xba
            cmp.b spcScanVal  // Compare with the current value we're scanning for
            bne scan_next_row   // No match?
            inc.b spcScanLen
            lda.b spcScanLen
            cmp.b #($0C + SPC_INIT_CODE_LENGTH)
            beq _found_free_ram
            inx
            bra _search_free_ram_inner
        scan_next_row:      // Move to the next row, i.e. (16 - (current_offset % 16)) bytes ahead. 
            rep #$20
            txa
            clc
            adc.w #$0010
            and.w #$FFF0
            tax
            sep #$20
            jmp _search_free_ram // Gotta keep searchin' searchin'..
            _search_free_ram_new_string:
            xba         // Restore the value we read from RAM
            cmp.b #$00
            beq _search_free_ram_new_string00
            cmp.b #$ff
            beq _search_free_ram_new_stringFF
            bra scan_next_row   // Neither $00 or $ff. Try the next row
            _search_free_ram_new_string00:
            lda.b spcFound00  
            bne scan_next_row   // We've already found a 00-string
            stz.b spcScanVal
            bra +
            _search_free_ram_new_stringFF:
            lda.b spcFoundFF
            bne scan_next_row   // We've already found an FF-string
            lda.b #$ff
            sta.b spcScanVal
+
            inc.b spcScanLen
            inx
            jmp _search_free_ram_inner   
    _found_free_ram:
    rep #$20
    txa
    sec
    sbc.b #($0B+SPC_INIT_CODE_LENGTH)
    tax
    sep #$20
    lda.b spcScanVal
    bne _found_stringFF  
    stx.b spcFree00           // This was a 00-string that we found
    lda.b #$1
    sta.b spcFound00
    jmp _search_free_ram         // Find a place to hide, searchin' searchin'..
    _found_stringFF:
    stx.b spcFreeFF           // This was an FF-string that we found
    lda.b #$1
    sta.b spcFoundFF
    
    _pick_best_address:
    lda.b spcFoundFF          // Prefer the FF-string if we've found one
    beq +
    ldx.b spcFreeFF
    stx.b spcExecAddr
    bra _addr_search_done
+
    lda.b spcFound00
    beq _addr_search_done
    ldx.b spcFree00
    stx.b spcExecAddr
    
    _addr_search_done:
    //=======================================================================
    
    // Copy fastloader to SNES RAM
    rep #$10
    sep #$20
    ldx.w #(SPC_FASL_LENGTH-2)
-
        lda.l spc700_fasl_code,x
        sta $7f0000,x
        dex
        bpl -
    // Modify some values/addresses in the fastloader   
    lda.l dsp_reg_data+$5c    // DSP KOF
    sta $7f000b
    lda.l dsp_reg_data+$4c    // DSP KON
    sta $7f002d
    lda.b spcExecAddr
    sta $7f0030
    lda.b spcExecAddr+1
    sta $7f0031
    
    // Send the fastloader to SPC RAM
    sendMusicBlockM($7f, $0000, $0002, SPC_FASL_LENGTH)
    
    // Start executing the fastloader
    startSPCExecM($0002)
    
    // Build code to initialize registers.
    jsr MakeSPCInitCode

    // Upload the SPC data to $00f8..$ffff
    sep #$20
    ldx.w #$00f8
    _send_by_fasl:
        lda $7f0000,x
        sta.w REG_APUIO1
        lda $7f0001,x
        sta.w REG_APUIO2
        txa
        sta.w REG_APUIO0
        waitForAudio0M()
        inx
        inx
        bne _send_by_fasl
    
    // > The SPC should be executing our initialization code now <

    phb         // Save DBR
    lda.b spcSongNr
    asl
    clc
    adc.b #SPC_DATA_BANK
    pha
    plb     
    ldx.w #0
    _copy_spc_page0:
        lda $8000,x // Read from ROM
        sta.w REG_APUIO1
        txa
        sta.w REG_APUIO0
        waitForAudio0M()
        inx
        cpx.w #$f0
        bne _copy_spc_page0
    // Send the init value for SPC registers $f0 and $f1
    lda #$0a
    sta.w REG_APUIO1
    lda #$f0
    sta.w REG_APUIO0
    waitForAudio0M()
    lda.w $80f1
    and.b #7      // Mask out everything except the timer enable bits
    sta.w REG_APUIO1
    lda #$f1
    sta.w REG_APUIO0
    waitForAudio0M()
    plb         // Restore DBR
    
    // Write the init values for the SPC I/O ports
    lda $7f00f7
    sta.w REG_APUIO3
    lda $7f00f6
    sta.w REG_APUIO2
    lda $7f00f4
    sta.w REG_APUIO0
    lda $7f00f5
    sta.w REG_APUIO1
    
    plp
    plb
    rtl

CopySPCMemoryToRam:
    // Copy music data from ROM to RAM, from the end backwards.
    rep #$10        // xy in 16-bit mode.
    sep #$20
    ldx #$7fff          // Set counter to 32k-1.
 
    phb                 // Save DBR
    lda.b spcSongNr
    asl
    clc
    adc.b #SPC_DATA_BANK
    pha
    plb                 // Set DBR to spcSongNr*2 + SPC_DATA_BANK
-
    lda $8000,x         // Copy byte from first music bank.
    sta $7f0000,x
    dex
    bpl -
 
    lda.b spcSongNr
    asl
    clc
    adc.b #(SPC_DATA_BANK+1)
    pha
    plb         // Set DBR to spcSongNr*2 + SPC_DATA_BANK + 1
    ldx #$7fff          // Set counter to 32k-1.
-
    lda $8000,x         // Copy byte from second music bank.
    sta $7f8000,x
    dex
    bpl -
    
    plb         // restore DBR
 
    rts


// Loads the DSP init values in reverse order
InitDSP:
    rep #$10    // xy in 16-bit mode
    lda.b spcSongNr

    rep #$20     // 16-bit accum
    xba
    lda.w #0      // Clear high byte
    xba
    asl
    asl
    asl
    asl
    asl
    asl
    asl
    clc
    adc.w #$007F
    tax         // x = spcSongNr*128 + 127
    sep #$20     // 8-bit accum
    
    ldy #$007F      // Reset DSP address counter.
-
    sep #$20
    tya                     // Write DSP address register byte.
    sta $7f0100            
    lda.l dsp_reg_data,x      
    sta $7f0101         // Write DSP data register byte.    
    phx                     // Save x on the stack.
    phy

    cpy #$006c
    beq _skip_dsp_write
    cpy #$007d
    beq _skip_dsp_write
    cpy #$004c
    beq _skip_dsp_write
    cpy #$005c
    bne +
    lda #$ff
    sta $7f0101
+
    // Send the address and data bytes to the DSP memory-mapped registers.
    sendMusicBlockM($7f, $0100, $00f2, $0002)

    _skip_dsp_write:
    
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
    
    rep #$10            // Restore x.
    ply
    plx

    // Loop if we haven't done 128 registers yet.
    dex
    dey
    cpy #$FFFF
    bne -
    rts
    

MakeSPCInitCode:
     // Constructs SPC700 code to restore the remaining SPC state and start
     // execution.
 
    rep #$20
    lda.w #0
    ldx.w #0            // Make sure A and X are both clear
    rep #$10

    ldy.b spcExecAddr   // The address in SPC RAM that we're going
                        // to copy the init routine to (the same address
                        // is used in SNES RAM).
    sep #$20

    lda.b spcSongNr
    asl
    asl
    asl
    tax             // x = spcSongNr * 8

    phb             // Save DBR
    lda.b #$7f
    pha
    plb             // Set DBR=$7f (RAM)
    
    phx             // Save X
    ldx.w #0
-
    lda.l spc700_init_code,x
    sta $0000,y         // Store in SNES RAM
    iny
    inx
    cpx.w #SPC_INIT_CODE_LENGTH
    bne -
    plx             // Restore X

    ldy.b spcExecAddr
    
    // Patch the init routine with the correct register values etc. for this song
    lda.l SPC_REG_ADDR+6,x    // SP
    sta $0001,y
    lda.l SPC_REG_ADDR+5,x    // PSW
    sta $0004,y
    lda.l dsp_reg_data+$7d    // EDL
    sta $0019,y
    lda.l SPC_REG_ADDR+2,x    // A
    sta $001c,y
    lda.l SPC_REG_ADDR+3,x    // X
    sta $001e,y
    lda.l SPC_REG_ADDR+4,x    // Y
    sta $0020,y
    lda.l dsp_reg_data+$6c    // FLG
    sta $0025,y
    rep #$20
    lda.l SPC_REG_ADDR,x      // PC
    sta $0029,y
    sep #$20
    
    plb             // Restore DBR
    rts


// spcSourceAddr - source address
// x - dest address
// y - count
CopyBlockToSPC:
    rep #$10
    
    // Wait until audio0 is $aa
    sep #$20
    lda.b #$aa
    waitForAudio0M()

    stx.w REG_APUIO2      // Write it to APU Port2 as well
    
    // Transfer count to x.
    phy
    plx

    // Send $01cc to AUDIO0 and wait for echo.
    lda #$01
    sta.w REG_APUIO1
    lda #$cc
    sta.w REG_APUIO0
    waitForAudio0M()

    sep #$20

    // Zero counter.
    ldy.w #$0000
CopyBlockToSPC_loop:
    lda [spcSourceAddr],y

    sta.w REG_APUIO1
    
    // Counter -> A
    tya

    sta.w REG_APUIO0

    // Wait for counter to echo back.
    waitForAudio0M()

    // Update counter and number of bytes left to send.
    iny
    dex
    bne CopyBlockToSPC_loop

    sep #$20
    
    // Send the start of IPL ROM send routine as starting address.
    ldx.w #$ffc9
    stx.w REG_APUIO2
    
    // Tell the SPC we're done transfering for now
    lda.b #0
    sta.w REG_APUIO1
    lda.b spcMirrorVal    // This value is filled out by waitForAudio0M()
    clc
    adc #$02        
    sta.w REG_APUIO0

    // Wait for counter to echo back.
    waitForAudio0M()

    rep #$20
    
    rts
 
// Starting address is in x.
StartSPCExec:
    // Wait until audio0 is $aa
    sep #$20
    lda #$aa
    waitForAudio0M()

    // Send the destination address to AUDIO2.
    stx.w REG_APUIO2

    // Send $00cc to AUDIO0 and wait for echo.
    lda #$00
    sta.w REG_APUIO1
    lda #$cc
    sta.w REG_APUIO0
    waitForAudio0M()

    rts


    bank0()
spc700_init_code:
 db $cd, $00     // mov  x,#$xx      (the value is filled in later)
 db $bd      // mov  sp,x
 db $cd, $00     // mov  x,#$xx      (the value is filled in later)
 db $4d      // push x
 db $cd, $00     // mov   x,#0
 db $3e, $f4         // -: cmp   x,$f4
 db $d0, $fc         //    bne   -
 db $e4, $f5         //    mov   a,$f5
 db $d8, $f4         //    mov   $f4,x
 db $af      //    mov   (x)+,a
 db $c8, $f2     //    cmp   x,#$f2
 db $d0, $f3     //    bne   -
 db $8f, $7d, $f2    // mov  $f2,#$7d
 db $8f, $00, $f3    // mov  $f3,#$xx    (the value is filled in later)
 db $e8, $00     // mov  a,#$xx      (the value is filled in later)
 db $cd, $00     // mov  x,#$xx      (the value is filled in later)
 db $8d, $00     // mov  y,#$xx      (the value is filled in later)
 db $8f, $6c, $f2    // mov  $f2,#$6c
 db $8f, $00, $f3    // mov  $f3,#$xx    (the value is filled in later)
 db $8e      // pop  psw
 db $5f, $00, $00    // jmp  $xxxx       (the address is filled in later)
 // 43 bytes
 // minimum 22 cycles per byte transfered


// Code for transferring data to SPC RAM at $00f8..$ffff
spc700_fasl_code:
 db $cd, $00        // 0002 mov x,#0
 db $8d, $f8        // 0004 mov y,#$f8
 db $8f, $00, $f1   // 0006 mov $f1, #0
 db $8f, $5c, $f2   // 0009 mov $f2, #$5c 
 db $8f, $00, $f3   // 000c mov $f2, #$xx   (the value is filled in later)
 db $7e, $f4        // 000f -: cmp   y,$f4  
 db $d0, $fc        // 0011    bne   -
 db $e4, $f5        // 0013    mov   a,$f5
 db $d6, $00, $00   // 0015    mov   $0000+y,a
 db $cb, $f4        // 0018    mov   $f4,y
 db $e4, $f6        // 001a    mov   a,$f6
 db $d6, $01, $00   // 001c    mov   $0001+y,a
 db $fc             // 001f    inc   y
 db $fc             // 0020    inc   y
 db $d0, $ec        // 0021    bne   - 
 db $ac, $17, $00   // 0023    inc   $0017
 db $ac, $1e, $00   // 0026    inc   $001e
 db $d0, $e4        // 0029    bne   -
 db $8f, $4c, $f2   // 002b mov   $f2, #$4c 
 db $8f, $00, $f3   // 002e mov   $f2, #$xx     (the value is filled in later)
 db $5f, $00, $00   // 0031 jmp   $xxxx     (the address is filled in later)
 // 50 bytes
 // minimum 17.55 cycles per byte transfered
 
// SPC-700 register values
    bank0()
SPC_REG_ADDR:
    insert spc_reg_data, {SPC_BINARY}, $00025, $0008
    insert dsp_reg_data, {SPC_BINARY}, $10100, $0080

// The actual 64k SPC RAM dump
    bank3()
    insert spc_bin_low32k, {SPC_BINARY}, $0100, $8000

    bank4()
    insert spc_bin_hi32k, {SPC_BINARY}, $8100, $8000

// vim:ft=bass
