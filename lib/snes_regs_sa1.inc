include "snes_regs.inc"

// SA-1 registers, assume 8 bits wide unless stated otherwise

//SA-1 CPU control
constant SA1_CCNT($2200) // idrn 3210, SCPU access: W
//	i = set IRQ, 0 disable 1 enable
//	d = rdy b, 0 ready 1 wait
//	r = SA-1 cpu reset, 0 boot 1 reset and stop. write 0 to boot I guess
//	n = SA-1 nmi from SCPU, 0 disable 1 enable
//	3210 = message from SCPU to SA-1
constant SA1_CCNT_IRQ($80)
constant SA1_CCNT_WAIT($40)
constant SA1_CCNT_STOP($20)
constant SA1_CCNT_NMI($10)

//SCPU Interrupt Enable
constant SA1_SIE($2201) // i-c- ----, SCPU access: W
//	i = IRQ, 0 disable 1 enable
//	c = character conversion DMA IRQ, 0 disable 1 enable

//SCPU Interrupt Clear
constant SA1_SIC($2202) // i-c- ----, SCPU access: W
//	i = IRQ clear from SA-1, 0 no change 1 clear
//	c = character conversion DMA IRQ clear, 0 no change 1 clear

constant SA1_CRV($2203) // SA-1 reset vector 16 bits, SCPU access: W
constant SA1_CNV($2205) // SA-1 NMI vector 16 bits, SCPU access: W
constant SA1_CIV($2207) // SA-1 IRQ vector 16 bits, SCPU access: W

//SCPU Controll
constant SA1_SCNT($2209) // qi-n 3210, SA-1 access: W
//	q = IRQ from SA-1 to SCPU, 0 disable irq 1 enable
//	i = SCPU IRQ vector selection, 0 game pak rom 1 $220E
//	n = SCPU NMI vector selection, 0 game pak rom 1 $220C
//	3210 = message from SA-1 to SCPU 
constant SA1_SCNT_IRQV_SIV($40)
constant SA1_SCNT_NMIV_SNV($10)

// SA-1 Interrupt enable
constant SA1_CIE($220A) // itdn ----, SA-1 access: W
//	i = irq control from SCPU to SA-1, 0 disable 1 enable
//	t = irq control from timer to SA-1, 0 disable 1 enable
//	d = irq control to SA-1 at end of SA-1 DMA, 0 disable 1 enable
//	n = nmi control from SCPU to SA-1, 0 disable 1 enable

// SA-1 Interrupt clear
constant SA1_CIC($220B) // itdn ---, SA-1 access: W
//	i = irq clear from SCPU to SA-1, 0 no change 1 clear
//	t = irq clear from timer to SA-1, 0 no change 1 clear
//	d = irq clear to SA-1 at end of SA-1 DMA, 0 no change 1 clear
//	n = nmi clear from SCPU to SA-1, 0 no change 1 clear

constant SA1_SNV($220C) // SCPU NMI vector 16 bits, SCPU W
constant SA1_SIV($220E) // SCPU IRQ vector 16 bits, SCPU W
constant SA1_TMC($2210) // s--- --vh, SA-1 access: W
//	s = select HV timer, 0 hv timer 1 linear timer
//	vh= V count, H count enable
//		00: disable H and V
//		01: enable H only, IRQ at HCNT value
//		10: enable V only, IRQ at VCNT value
//		11: enable both, IRQ at HCNT on scanline VCNT

constant SA1_CTR($2211) // SA-1 access: W
//	Writing any value to this register sets the timer to 0 and restarts it. (Linear timer?)

constant SA1_HCNT($2212) // 9 bits, SA-1 access: W
//	if $2211 set to linear timer:
//		Lower 9 bits of the timer IRQ linear counter (0-511)
//	else
//		Timer IRQ horizontal count value (0-340)
constant SA1_VCNT($2214) // 9 bits, SA-1 access: W
//	if $2211 set to linear timer:
//		Upper 9 bits of the timer IRQ linear counter (0-511)
//	else
//		Timer IRQ vertical count value (NTSC 0-261, PAL 0-311)

//The following 4 registers are used to set memory mapping for banks C,D,E and F respectively.
constant SA1_CXB($2220) // b--- -aaa, SCPU access: W
//	When B is set, accessing an address in $00-1F:8000-FFFF will return (aaa << 20) | (addr & 0x0F7FFF).
//	If B is not set accessing an address in $00-1F:8000-FFFF will return  (addr & 0x0f7fff)
//	$C0-$CF:0000-FFFF will always return (aaa << 20) | (addr & 0x0FFFFF)

constant SA1_DXB($2221) // b--- -aaa, SCPU access: W
//	see above but replace $00-1F with $20-3F, $C0-CF with $D0-DF

constant SA1_EXB($2222) // b--- -aaa, SCPU access: W
//	$80-9F, $E0-EF

constant SA1_FXB($2223) // b--- -aaa, SCPU access: W
//	$A0-BF, $F0-FF

constant SA1_BMAPS($2224) // ---s ssss, SCPU access: W
//	s = BW-RAM address image mapping for SCPU.
//		The BW-RAM image to be mapped to address range $6000-7FFF of banks $00-3F and $80-BF is user selectable from $00-1F.
//		This is image is mirrored across all lorom banks.

constant SA1_BMAP($2225) // sccc cccc, SA-1 access: W
//	c = BW-RAM address image mapping for SA-1
//		This selects the BW-RAM image to be mapped to the SA-1 at addresses $6000-7FFF of banks $00-3F and $80-BF.
//	s = specifies the BW-RAM source to be projected
//		0 banks $40-43 are displayed in 32 blocks using bits 0-4
//		1 banks $60-6F are displayed in 128 blocks using bits 0-6
//	The image is mirrored across all lorom ($00-3F/$80-BF:$6000-7FFF)

constant SA1_SBWE($2226) // s--- ----, SCPU access: W
//	s = cancels BW-RAM write protection from SCPU
//		0 protect, 1 write enable

constant SA1_CBWE($2227) // c--- ----, SA-1 access: W
//	c = Cancels BW-RAM write protection from SA-1
//		0 protect, 1 write enable

constant SA1_BWPA($2228) // ---- bbbb, SCPU access: W
//	b = BW-RAM write protected area setting (bank $40-43)
//		write protected area size: 2048 << bbbb
//	At start-up all areas are write-protected.

constant SA1_SIWP($2229) // ssss ssss, SCPU access: W
//	s = SA-1 I-RAM write protection setting, works differently from BW-RAM write protection in that each bit enables/disables writing to a 256 byte area.
//		0 write disable, 1 enable (for the corresponding area)
//		$01 to enable writing $3000-30FF, $02 $3100-31FFF, $03 $3000-31FF

constant SA1_CIWP($222A) // cccc cccc, SA-1 access: W
//	c = SA-1 I-RAM write protection setting, works same as $2229

constant SA1_DCNT($2230) // cpel -dss, SA-1 access: W
//	c = DMA enable control, 0 disable 1 enable
//	p = DPrio processing priority between SA-1 and DMA, 0 SA-1 priority, 1 DMA priority
//	d = destination device, 0 SA-1 I-RAM, 1 BW-RAM
//	s = source device, 00 gamepak rom, 01 BW-RAM, 10 SA-1 I-RAM
//	e = DMA mode selection, 0 normal DMA, 1 character conversion DMA
//	l = Character conversion DMA type,
//		0 SA-1 -> SA-1 I-RAM write (CHR conv 2)
//		1 BW-RAM -> SA-1 I-RAM transfer (CHR conv 1)

constant SA1_CDMA($2231) // h--s sscc, SCPU & SA-1 access: W
//	h = 1 to end character conversion 1, when character conversion 1 is completed, CHDEND is set to 1 by the SCPU.
//	c = character conversion DMA color mode,
//		00 8bpp
//		01 4bpp
//		10 2bpp
//	s = number of virtual VRAM horizontal characters
//		sss		number of characters
//		000		1
//		001		2
//		010		4
//		011		8
//		100		16
//		101		32

constant SA1_SDAL($2232) // low 8 bits, SCPU & SA-1 access: W
constant SA1_SDAM($2233) // mid 8 bits, SCPU & SA-1 access: W
constant SA1_SDAH($2234) // high 8 bits, SCPU & SA-1 access: W
constant SA1_SDA($2232) // 24 bits, SCPU & SA-1 access: W
//	bit 0-23: DMA source device A start address
//		Data should be stored to the SDA registers in the order of low -> middle -> high

constant SA1_DDAL($2235) // low 8 bits, SCPU & SA-1 access: W
constant SA1_DDAM($2235) // mid 8 bits, SCPU & SA-1 access: W
constant SA1_DDAH($2235) // high 8 bits, SCPU & SA-1 access: W
constant SA1_DDA($2235) // 24 bits, SCPU & SA-1 access: W
//	bit 0-23: DMA destination device start address
//		When transmitting to SA-1 IRAM, DMA transfer is initiated by the write to register $2236
//		When transmitting to BWRAM, DMA transfer is initiated by the write to register $2237
//		Data should be stored to the DDA registers in the order of low -> middle -> high

constant SA1_DTC($2238) // 16 bits, SA-1 access: W
//	bit 0-15: Number of bytes for DMA transmission

constant SA1_BBF($223F) // s--- ----, SA-1 access: W
//	s = BW-RAM bitmap logical space format setting from the perspective of the SA-1.
//		0 4bpp, 1 2bpp

constant SA1_BRF($2240) // 16 BYTES, SA-1 access: W
//	bytes 0-7: buffer 1
//	bytes 8-15: buffer 2

constant SA1_MCNT($2250) // ---- --cm, SA-1 access: W
//	Arithmetic control register
//		c	d	type of operation
//		0	0	Multiplication
//		0	1	Division
//		1	0	Cumulative sum
//	Store a 1 to c to clear the result register during cumulative sum operations.

constant SA1_MA($2251) // 16 bits, SA-1 access: W
//	bit 0-15: Multiplicand or dividend (16 bit signed) depending on $2250 setting.
//	Data in this register is retained after multiplication, but not division(?)

constant SA1_MB($2253) // 16 bits, SA-1 access: W
//	bit 0-15: Multiplier or divisor.
//		Signed when used for multiplication, unsigned for division.
// The arithmetic operation is executed following a write to register $2254.
// Value is not retained after operation, this register must be reset each time an operation is performed.

constant SA1_VBD($2258) // h--- vvvv, SA-1 access: W
//	h = variable-length data read mode
//		1: auto-increment mode
//		0: fixed mode
//	v =  significant bit length of data previously stored.
//	v	v	v	v	Data length (bits)
//	0	0	0	0	16 bits
//	0	0	0	1	1 bits
//	0	0	1	0	2 bits
//	...
//	1	1	1	1	15 bits

constant SA1_VDA($2259) // 24 bits, SA-1 access: W
//	bit 0-23: Game pak rom variable-length bit area start address
//		Variable-length bit execution begins with a write to $225B

constant SA1_SFR($2300) // ivdn cccc, SCPU access: R
//	i = IRQ flag from SA-1, 0 no IRQ, 1 IRQ
//	v = SCPU IRQ vector setting, 0 gamepak rom data, 1 SA1_SIV reg data
//	d = Character conversion DMA IRQ flag, 0 no IRQ, 1 IRQ (character conversion 1 stand-by)
//	n = SCPU NMI vector setting, 0 gamepak rom data, 1 SA1_SNV reg data
//	c = message port from SA-1: 0-15
// Note: reading this register does not clear its contents.

constant SA1_CFR($2301) // itdn ssss
//	i = IRQ flag from SCPU, 0 no IRQ, 1 IRQ
//	t = IRQ flag from timer, 0 no IRQ, 1 IRQ
//	d = IRQ flag at the end of DMA, 0 no IRQ, 1 IRQ (end of DMA)
//	n = NMI flag from SCPU, 0 no NMI, 1 NMI
//	s = Message port from SCPU 0-15
//	Note: reading this register does not clear its contents.

constant SA1_HCR($2302) // 9 bits, SA-1 access: R
//	bits 0-8 = HV timer H-count (0-340) read
//	Linear timer: lower 9-bit count (0-511) read
//	All HV counter values are latched when register $2302 is read.

constant SA_VCR($2304) // 9 bits, SA-1 access: R
//	bits 0-8 = HV timer V-count (0-261/0-311) read
//	Linear timer: upper 9-bit counter value (0-511) read

constant SA1_MR($2306) // to $230A, 40 bits, SA-1 access: R
//	Arithmetic result for mult/div
//		Multiplication: 16(signed) * 16(S) = 32(S)
//		Division: 16(S) / 16(unsigned) = 16(S) bits 0-15
//								Remainder: 16(U) bits 16-31
//		Cumulative sum: sigma(16(S) * 16(S)) = 40(S) all bits

constant SA1_OF($230B) // o--- ---- SA-1 access: R
//	o = overflow flag, 1 overflow, 0 no overflow

constant SA1_VDP($230C) // 16 bits, SA-1 access: R
//	bits 0-15: The 16 bit data resulting from barrel-shifting the values stored in the VBD register ($2258)

constant SA1_VC($230E) // vvvv vvvv SA-1 acces: R
//	v = SA-1 device version

// Bank Range -- Content
// $00-$1F    -- ROM (CXB) (LoROM)
// $20-$3F    -- ROM (DXB) (LoROM)
// $40-$4F    -- BW-RAM
// $50-$5F    -- Unmapped
// $60-$6F    -- (SA-1 only) "Virtual" BW-RAM.
// $70-$7D    -- Unmapped
// $7E-$7F    -- (SNES only) WRAM
// $80-$9F    -- ROM (EXB) (LoROM)
// $A0-$BF    -- ROM (FXB) (LoROM)
// $C0-$CF    -- ROM (CXB) (HiROM)
// $D0-$DF    -- ROM (DXB) (HiROM)
// $E0-$EF    -- ROM (EXB) (HiROM)
// $F0-$FF    -- ROM (FXB) (HiROM)

//	Memory map (SNES side)
// $00-$3F/$80-$BF:2200-23FF		I/O Ports
// $00-$3F/$80-$BF:3000-37FF		I-RAM (2KiB, on chip, 10.74MHz)
// $00-$3F/$80-$BF:6000-7FFF		One mappable 8KiB BW-RAM block
// $00-$3F/$80-$BF:8000-FFFF		Four mappable 1MiB lorom blocks (max 8MiB)
// $40-$4F:0000-FFFF				Entire 256KiB BW-RAM (mirrors in $44-4F)
// $C0-$FF:0000-FFFF				Four mappable 1MiB hirom blocks (max 8MiB)

//	Memory map (SA-1 side)
// Same as on SNES Side (of course without access to SNES internal WRAM and
// I/O ports), plus following additional areas:
// $00-3F/$80-BF:0000-07FF	I-RAM (at both $0000-07FF and $3000-37FF)
// $60-6F:0000-FFFF			BW-RAM mapped as 2bit or 4bit pixel buffer
//
// Some other differences to SNES Side are:
// I/O Ports are different, on SA-1 side, the mappable BW-RAM area (at 6000h-7FFFh) can be also assigned as 2bit/4bit pixel buffer (on SNES Side it's always normal 8bit memory).

// vim:ft=snes
