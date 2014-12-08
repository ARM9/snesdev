//============= (Key: R=Read, W=Write)
// SNES SPC700
//=============
// Memory Map
constant SPCPAGE0($0000)    // RAM Page 0 (Typically Used For CPU Pointers/Variables)  240B/RW
// $00F0..$00FF - I/O Ports (Writes Are Also Passed To RAM)
constant SPCPAGE1($0100)    // RAM Page 1 (Typically Used For CPU Stack)               256B/RW
constant SPCRAM($0200)      // RAM (Code, Data, Dir-Table, BRR-Samples, Echo-Buffer) 64960B/RW
constant SPCIPL($FFC0)      // 64-Byte IPL Boot ROM Or RAM (Selectable Via Port $00F1)  64B/RW

// I/O Ports (CPU Includes 16 Memory Mapper Ports At Address $00F0..$00FF)
constant REG_TEST($F0)      // Testing Functions                                         1B/W
constant REG_CONTROL($F1)   // Timer, I/O & ROM Control                                  1B/W
constant REG_DSPADDR($F2)   // DSP Register Index                                        1B/RW
constant REG_DSPDATA($F3)   // DSP Register Data                                         1B/RW
constant REG_CPUIO0($F4)    // CPU Input & Output Register 0                             1B/W
constant REG_CPUIO1($F5)    // CPU Input & Output Register 1                             1B/W
constant REG_CPUIO2($F6)    // CPU Input & Output Register 2                             1B/W
constant REG_CPUIO3($F7)    // CPU Input & Output Register 3                             1B/W
constant REG_AUXIO4($F8)    // External I/O Port P4 (S-SMP Pins 34-27)                   1B/RW
constant REG_AUXIO5($F9)    // External I/O Port P5 (S-SMP Pins 25-18)                   1B/RW
constant REG_T0DIV($FA)     // Timer 0 Divider  (8000Hz Clock Source)                    1B/W
constant REG_T1DIV($FB)     // Timer 1 Divider  (8000Hz Clock Source)                    1B/W
constant REG_T2DIV($FC)     // Timer 2 Divider (64000Hz Clock Source)                    1B/W
constant REG_T0OUT($FD)     // Timer 0 Output                                            1B/R
constant REG_T1OUT($FE)     // Timer 1 Output                                            1B/R
constant REG_T2OUT($FF)     // Timer 2 Output                                            1B/R

// DSP Registers (128 DSP Registers Are Indirectly Accessed Via I/O Ports $00F2/$00F3)
constant DSP_MVOLL($0C)     // Left  Channel Master Volume                               1B/RW
constant DSP_MVOLR($1C)     // Right Channel Master Volume                               1B/RW
constant DSP_EVOLL($2C)     // Left  Channel Echo   Volume                               1B/RW
constant DSP_EVOLR($3C)     // Right Channel Echo   Volume                               1B/RW
constant DSP_KON($4C)       // Voice 0..7 Key On  Flags                                  1B/W
constant DSP_KOFF($5C)      // Voice 0..7 Key Off Flags                                  1B/RW
constant DSP_FLG($6C)       // DSP Reset, Mute, Echo-Write Flags & Noise Clock           1B/RW
constant DSP_ENDX($7C)      // Voice 0..7 End Flags                                      1B/R

constant DSP_EFB($0D)       // Echo Feedback Volume                                      1B/RW
constant DSP_UNUSED($1D)    // Unused Byte (1 Byte Of General-Purpose RAM)               1B/RW
constant DSP_PMON($2D)      // Voice 0..7 Pitch Modulation Enable Flags                  1B/RW
constant DSP_NON($3D)       // Voice 0..7 Noise Enable Flags                             1B/RW
constant DSP_EON($4D)       // Voice 0..7 Echo  Enable Flags                             1B/RW
constant DSP_DIR($5D)       // Sample Table Address     (DIR * $100)                     1B/RW
constant DSP_ESA($6D)       // Echo Ring Buffer Address (ESA * $100)                     1B/RW
constant DSP_EDL($7D)       // Echo Delay (Ring Buffer Size)                             1B/RW

constant DSP_FIR0($0F)      // Echo FIR Filter Coefficient 0                             1B/RW
constant DSP_FIR1($1F)      // Echo FIR Filter Coefficient 1                             1B/RW
constant DSP_FIR2($2F)      // Echo FIR Filter Coefficient 2                             1B/RW
constant DSP_FIR3($3F)      // Echo FIR Filter Coefficient 3                             1B/RW
constant DSP_FIR4($4F)      // Echo FIR Filter Coefficient 4                             1B/RW
constant DSP_FIR5($5F)      // Echo FIR Filter Coefficient 5                             1B/RW
constant DSP_FIR6($6F)      // Echo FIR Filter Coefficient 6                             1B/RW
constant DSP_FIR7($7F)      // Echo FIR Filter Coefficient 7                             1B/RW

constant DSP_VVOLL($00)    // Voice Left  Volume                                      1B/RW
constant DSP_VVOLR($01)    // Voice Right Volume                                      1B/RW
constant DSP_VPITCHL($02)  // Voice Pitch Scaler  (Lower 8bit)                        2B/RW
constant DSP_VPITCHH($03)  // Voice Pitch Scaler  (Upper 6bit)                        1B/RW
constant DSP_VSRCN($04)    // Voice Source Number (0-255)                             1B/RW
constant DSP_VADSR1($05)   // Voice ADSR Settings (Lower 8bit)                        2B/RW
constant DSP_VADSR2($06)   // Voice ADSR Settings (Upper 8bit)                        1B/RW
constant DSP_VGAIN($07)    // Voice Gain Settings                                     1B/RW
constant DSP_VENVX($08)    // Voice Current Envelope Value                            1B/R
constant DSP_VOUTX($09)    // Voice Current Sample   Value                            1B/R
constant DSP_VUNUSEDA($0A) // Voice Unused Byte A (1 Byte Of General-Purpose RAM)     1B/RW
constant DSP_VUNUSEDB($0B) // Voice Unused Byte B (1 Byte Of General-Purpose RAM)     1B/RW
constant DSP_VUNUSEDC($0E) // Voice Unused Byte C (1 Byte Of General-Purpose RAM)     1B/RW

// $80..$FF - Read-Only Mirror Of $00..$7F

macro align(bytes) {
  while (pc() & ({bytes}-1)) {
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
// vim:ft=bass
