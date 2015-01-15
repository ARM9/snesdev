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

// vim:ft=snes
