
macro align(size) {
  while (pc() % {size}) {
    nop
  }
}

// SPC700 Macros
macro WDSP(REG, DATA) {
  lda #{REG}
  ldy {DATA}
  stw REG_DSPADDR
}

macro WDSP_REG(REG) {
  lda #{REG}
  stw REG_DSPADDR
}

macro SPCInit() { // SPC700 Initialisation
  WDSP(DSP_FLG, #$20)  // Disable Echo Buffer Writes
  WDSP(DSP_KON, #$00)  // Reset Key On Flags
  WDSP(DSP_KOFF, #$FF) // Set Key Off Flags
  WDSP(DSP_PMON, #$00) // Reset Pitch Modulation Enable Flags
  WDSP(DSP_NON, #$00)  // Reset Noise Enable Flags
  WDSP(DSP_EON, #$00)  // Reset Echo On Flags
  WDSP(DSP_EVOLL, #0)  // Reset Echo Volume Left
  WDSP(DSP_EVOLR, #0)  // Reset Echo Volume Right
}

macro scope SPCWaitMS(AMOUNT) { // Wait For MilliSecond Amount (Granularity = 1ms, Max Wait = 255ms)
  ldy #{AMOUNT}
  str REG_T2DIV=#$40
  str REG_CONTROL=#$04
L{#}:
  lda.b REG_T2OUT
  beq L{#}
  dey
  bne L{#}
}

macro scope SPCRamClear(ADDR, AMOUNT) { // Clear SPC RAM in 256 Byte Chunks * Amount
  lda #$00 // Clear Byte
  ldx #{AMOUNT} // Clear Amount High Byte
  ldy #$00 // Echo Buffer Index
L{#}:
  sta {ADDR},y // Store Clear Byte Into RAM Using 16bit Offset
  iny // Increment Y Index
  bne L{#} // IF (Y != 0) Loop Clear Byte

  variable modifyoffset(L{#})
  inc modifyoffset + 2 // Self Modify (Increment) 16Bit ADDR Offset Above
  dex // Decrement X Clear Amount High Byte
  bne L{#} // Loop Another 256 Byte Chunk
}

macro SPCBoot() { // Run SPC Bootloader
  str REG_CONTROL=#$80 // REG_CONTROL = $80 (Boot ROM ON)
  jmp SPCIPL // Jump To $FFC0 (Start of Boot ROM)
}

// 65C816 Macros
macro scope WaitAPUIO(PORT) {
L{#}:
  cmp.w REG_APUIO{PORT}
  bne L{#}
}

macro SPCWaitBoot() { // Wait For SPC To Boot (Call At first Use Of SPC & After Re-Run of BootROM)
  lda.b #$AA
  WaitAPUIO(0)
  sta.w REG_APUIO0 // Clear In Case It Contains $CC
  lda.b #$BB
  WaitAPUIO(1)
}

macro SPCExecute(ADDR) { // Starts Executing At SPC ADDR X
  ldx.w #{ADDR}
  stx.w REG_APUIO2
  stz.w REG_APUIO1
  lda.w REG_APUIO0
  clc
  adc.b #$22
  sta.w REG_APUIO0
  WaitAPUIO(0) // Wait For Acknowledgement
}

macro SPCLoadByte() { // Loads Byte A To SPC & Increments X
  sta.w REG_APUIO1
  txa // Ready Signal
  sta.w REG_APUIO0
  inx // Increment X
  WaitAPUIO(0) // Wait For Acknowledgement
}

macro scope SPCBeginUpload() { // Starts Upload To SPC ADDR X & Sets X To 0 For Use As Index With SPCLoadByte
  stx.w REG_APUIO2
  lda.w REG_APUIO0 // Send Command
  clc
  adc.b #$22
  bne L{#} // Special Case Fully Verified
  inc
L{#}:
  sta.w REG_APUIO1
  sta.w REG_APUIO0
  WaitAPUIO(0) // Wait For Acknowledgement
  ldx.w #0 // Initialize X Index To 0
}

macro scope TransferBlockSPC(SRC_ADDR, SPC_ADDR, SIZE) { // Transfer A Block Of Data To SPC RAM
  ldx.w #{SPC_ADDR}
  SPCBeginUpload()
L{#}:
  lda.l {SRC_ADDR},x
  SPCLoadByte()
  cpx.w #{SIZE}
  bne L{#}
}

macro WriteDSP(REG, BYTE) { // Write Byte To SPC-700 DSP Register
  ldx.w #REG_DSPADDR // Do A Two Byte Upload To $00F2..$00F3, Setting DSP Register & Data Byte
  SPCBeginUpload()
  lda.b #{REG}
  SPCLoadByte() // DSP REG To $F2
  lda.b #{BYTE}
  SPCLoadByte() // DSP DATA To $F3
}

macro WriteCTRL(BYTE) { // Write Byte To SPC-700 Control Register
  ldx.w #REG_CONTROL // Do A Byte Upload To $00F1, Writing Control Register
  SPCBeginUpload()
  lda.b #{BYTE}
  SPCLoadByte() // Control DATA To $F1
}

constant C#(11)
constant D(10)
constant D#(9)
constant E(8)
constant F(7)
constant F#(6)
constant G(5)
constant G#(4)
constant A(3)
constant A#(2)
constant B(1)
constant C(0)

macro SetPitch(voice, note, octave, C9Pitch) {
  variable pitch({C9Pitch})

  if {note} >= 1 {
    pitch = ((pitch * 1000000000) / 1059463094)
  }
  if {note} >= 2 {
    pitch = ((pitch * 1000000000) / 1059463094)
  }
  if {note} >= 3 {
    pitch = ((pitch * 1000000000) / 1059463094)
  }
  if {note} >= 4 {
    pitch = ((pitch * 1000000000) / 1059463094)
  }
  if {note} >= 5 {
    pitch = ((pitch * 1000000000) / 1059463094)
  }
  if {note} >= 6 {
    pitch = ((pitch * 1000000000) / 1059463094)
  }
  if {note} >= 7 {
    pitch = ((pitch * 1000000000) / 1059463094)
  }
  if {note} >= 8 {
    pitch = ((pitch * 1000000000) / 1059463094)
  }
  if {note} >= 9 {
    pitch = ((pitch * 1000000000) / 1059463094)
  }
  if {note} >= 10 {
    pitch = ((pitch * 1000000000) / 1059463094)
  }
  if {note} == 11 {
    pitch = ((pitch * 1000000000) / 1059463094)
  }

  if {note} {
    pitch = (pitch >> (8-{octave}))
  }
  if ! {note} {
    pitch = (pitch >> (9-{octave}))
  }

  WDSP({voice}<<4|DSP_VPITCHL, #pitch & $FF) // Voice X: Pitch (Lower Byte)
  WDSP({voice}<<4|DSP_VPITCHH, #pitch >> 8)  // Voice X: Pitch (Upper Byte)
}
// vim:ft=snes
