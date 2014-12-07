    include "snes_regs.inc"

// GSU registers

// During GSU operation, only SFR, SCMR, and VCR may be accessed by the SNES CPU.
constant GSU_R0($3000) //Default source/destination register
constant GSU_R1($3002) //PLOT instruction X coordinate
constant GSU_R2($3004) //PLOT instruction Y coordinate
constant GSU_R3($3006) // General purpose
constant GSU_R4($3008) //LMULT instruction lower 16 bits of result
constant GSU_R5($300A) // General purpose
constant GSU_R6($300C) //FMULT and LMULT instructions, multiplier
constant GSU_R7($300E) //MERGE instruction, source 1
constant GSU_R8($3010) //MERGE instruction, source 2
constant GSU_R9($3012) // General purpose
constant GSU_R10($3014) // General purpose (conventionally stack pointer)
constant GSU_R11($3016) //LINK instruction destination register, used for return address
constant GSU_R12($3018) //LOOP instruction counter
constant GSU_R13($301A) //LOOP instruction branch address
constant GSU_R14($301C) //Gamepak ROM address pointer for GETxx opcodes
constant GSU_R15($301E) //Program counter, write MSB to start operation
// Access from snes cpu for R0-R15: R/W

// SNES CPU access disabled  for COLR and POR registers
//constant GSU_COLR() Color register
// Access from snes cpu: -
// pppp pppp, p = palette entry used by plot instruction
//constant GSU_POR() Plot option register
// Access from snes cpu: -
// ---o fhdt
//	t = Transparency flag or rather whether to plot color 0 or not, 1 = plot color 0, 0 = don't plot color 0 (transparency on)
//		If t is on and the color register is 0, the plot circuit only changes the X coordinate (R1)
//	d = Dither flag, 1 = on (only valid in 4bpp mode?)
//		if(R1&1 == R2&1) lower 4 bits in the color register are plotted.
//		else plot upper 4 bits of color register
//	h = Upper 4 bits color, 1 = on (4bpp, or 8bpp with f set)
//		When enabled, the upper 4 bits in the source register are stored in the lower 4 bits
//		of the color register when using COLOR and GETC instructions.
//		This allows the data for 2 pixels to be stored in one byte.
//	f = Freeze upper 4 bits, 1 = on (8bpp only)
//		lock the upper 4 bits of the color register while processing the COLOR and GETC instructions and change the lower 4 bits only.
//	o = Sprite mode, set to 1 to specify the bitmap in sprite mode.
// Plot option register flags:
constant GSU_POR_OPAQUE($01)
constant GSU_POR_DITHER($02)
constant GSU_POR_COLOR_SRC_HIGH($04)
constant GSU_POR_FIX_HIGH_4BITS($08)
constant GSU_POR_OBJ($10)

constant GSU_SFR($3030) //Status/flag registers
// Access from snes cpu: R/W
// I--B HL21 -RGV SCZ- 
//	Z = Zero flag
//	C = Carry flag
//	S = Sign flag
//	V = Overflow flag
//	G = GSU is running (cleared on STOP) (set 0 to force GSU stop)
//	R = ROM[R14] read (0 = no, 1 = reading ROM via R14 address)
//	1 = Prefix flag \for ALT1, ALT2, ALT3
//	2 = Prefix flag /
//	L = Immediate lower 8 bit flag \Unknown, probably set/reset internally
//	H = Immediate upper 8 bit flag /when processing opcodes with imm operands
//	B = Prefix flag (for WITH prefix, used by MOVE/MOVES opcodes)
//	I = Interrupt Flag (reset on read, set on STOP) (also set if IRQ masked in $3037?)
constant GSU_SFR_GO($20)

constant GSU_BRAMR($3033) //Back-up (s)ram register
// Access from snes cpu: W
// ---- ---B, B = 0/1 disable/enable
// Some info from nocash:
// 	This register would be used only if the PCB does have a separate "Backup" RAM chip
//	mapped to 780000h-79FFFFh (additionally to the Game Pak RAM chip).
//	None of the existing PCBs have that extra SRAM chip, so the register has no practical function.
//	(Note: However, some PCBs do include a battery wired to Game Pak RAM chip, regardless,
//	that type of "backup" isn't affected by this register).
//	The "real" back-up RAM is also the game pak RAM (aka buffer RAM) and resides in bank $70-$71 (max 128KiB)
// Book says: Data becomes protected when the BRAM flag is reset (0) after saving data to the back-up RAM.

constant GSU_PBR($3034) //Program bank register
// Access from snes cpu: R/W
// bbbb bbbb, works like SNES CPU program bank register
constant GSU_ROMBR($3036) //Game pak rom bank register
// Access from snes cpu: R
// bbbb bbbb, used for ROM buffering, specifies the bank for instructions using the ROM buffer

constant GSU_CFGR($3037) //Config register
// Access from snes cpu: W
// I-M- ----, I = IRQ mask, set to 1 to mask GSU triggered IRQ
// M = multiplier speed select, 0 standard 1 high speed
// When operating at 21MHz (CLSR = $01) M must be 0(?) seems to work in 21mhz tho so screw that, give 1 cycle mult!
constant GSU_CFGR_FASTMUL($20)
constant GSU_CFGR_IRQ_MASK($80)


constant GSU_SCBR($3038) //Screen base register
// Access from snes cpu: W
// aaaa aaaa, a = start address (in 1KiB units ) for plot area

constant GSU_CLSR($3039) //Clock select register
// Access from snes cpu: W
// ---- ---S, S = Clock speed, 0 = 10.7MHz 1 = 21.4MHz 

// RON/RAN flags
constant GSU_SCMR($303A) //Screen mode register
// Access from snes cpu: W
// --hO Ahcc, O = RON, A = RAN, h = screen height, c = color depth mode
// Write 0 to RON/RAN (ROM/RAM enable) flags to temporarily put GSU in
// WAIT mode, this allows SCPU access to game pak ROM/RAM respectively.
// Write 1 to give game pak ROM/RAM access back to GSU and it will resume processing.
// hh settings: 00 = 128px, 01 = 160px, 10 = 192px, 11 = obj mode
// cc settings: 00 = 2bpp, 01 = 4bpp, 10 = not used, 11 = 8bpp
constant GSU_SCMR_RON($10)
constant GSU_SCMR_RAN($08)
constant GSU_SCMR_2BPP($00)
constant GSU_SCMR_4BPP($01)
constant GSU_SCMR_8BPP($03)
constant GSU_SCMR_H128($00)
constant GSU_SCMR_H160($04)
constant GSU_SCMR_H192($20)
constant GSU_SCMR_OBJ($24)

constant GSU_VCR($303B) //Version code register read only, 1 byte.
// Access from snes cpu: R
// There are 4 known versions, $01 = MARIO, $04 = GSU-2 ($02 = GSU? $03 = GSU-1 ????)

constant GSU_RAMBR($303C) //Game pak ram bank register
// Access from snes cpu: R
// ---- ---A, A = bank select ($70-71)

constant GSU_CBR($303E) //Cache base register
// Access from snes cpu: R
// cccc cccc cccc ----, This register specifies the starting address when data is loaded from ROM or gamepak RAM to cache RAM.

constant GSU_CACHE($3100) //GSU cache start exposed to scpu, writeable
//constant ccccccccc($32FF) //GSU cache end

//constant bbbbbbbbb($347F) // ?

// GSU2 (and probably 1) information below courtesy of nocash.emubase.de
// GSU2 memory map at SNES side
//	00-3F/80-BF:6000-7FFF  Mirror of 70:0000-1FFF (ie. FIRST 8K of Game Pak RAM)
//	70-71:0000-FFFF        Game Pak RAM       (128KiB max, usually 32K or 64K)
//	78-79:0000-FFFF        Additional "Backup" RAM  (128KiB max, usually none)
//
// GSU2 memory map at GSU Side
// 	00-3F:0000-7FFF  Mirror of LoROM at 00-3F:8000-FFFF (for "GETB R15" vectors)
// 	00-3F:8000-FFFF  Game Pak ROM in LoRom mapping (2MiB max)
// 	40-5F:0000-FFFF  Game Pak ROM in HiRom mapping (mirror of above 2MiB)
// 	70-71:0000-FFFF  Game Pak RAM       (128KiB max, usually 32K or 64K)
// 	PBR:0000-01FF    Code-Cache (when having manually stored opcodes in it)
// PBR can be set to both ROM/RAM regions (or cache region), ROMBR only to ROM region (00h-5Fh), RAMBR only to RAM region (70h-71h).

// vim:ft=bass
