; ROM header including interrupt vectors

.p816
.smart
.a8
.i16

;	Size Table
; This table encompasses ROM, RAM and SRAM size
;	$00 =>	none
;	$01 =>	$800 bytes		==	2 Kilobytes, amount of SRAM in Super Mario World
;	$02 =>	$1000 bytes		==	4 Kilobytes
;	$03 =>	$2000 bytes		==	8 Kilobytes
;	$04 =>	$4000 bytes		==	16 Kilobytes
;	$05 =>	$8000 bytes		==	32 Kilobytes, amount of (S?)RAM in Mario Paint
;	$06 =>	$10000 bytes	==	64 Kilobytes, amount of Expansion RAM in Stunt Race FX
;	$07 =>	$20000 bytes	==	128 Kilobytes, amount of RAM in Dezaemon - Kaite Tsukutte Asoberu
;	$08 =>	$40000 bytes	==	256 Kilobytes, supposedly minimum for ROM
;	$09 =>	$80000 bytes	==	512 Kilobytes, amount of ROM in Super Mario World
;	$0A =>	$100000 bytes	==	1 Megabyte, amount of ROM in Mario Paint
;	$0B =>	$200000 bytes	==	2 Megabytes
;	$0C =>	$400000 bytes	==	4 Megabytes
; Valid range for ROM: $08-$0C, emulators may support $05-$0C
; Valid range for SRAM: $00-$07
; Valid range for RAM: $00-$07 (this is only for SA-1 and GSU carts, see $FFBD)

;#	SNES Address	Length	Name
;1	$00:FFB0		2 bytes	Maker code
;2	$00:FFB2		4 bytes	Game code
;3	$00:FFB6		7 bytes	Fixed Value ($00)
;4	$00:FFBD		1 byte	Expansion RAM size (SA-1 and GSU)
;5	$00:FFBE		1 byte	Special version
;6	$00:FFBF		1 byte	Cartridge type

;#	SNES Address	Length	Name
;7	$00:FFC0		21 bytes Internal ROM Name
;8	$00:FFD5		1 byte	Map Mode
;9	$00:FFD6		1 byte	Cart type
;10	$00:FFD7		1 byte	ROM Size
;11	$00:FFD8		1 byte	SRAM Size
;12	$00:FFD9		1 byte	Destination code
;13	$00:FFDA		1 byte	Fixed value ($33)
;14	$00:FFDB		1 byte	Version #
;15	$00:FFDC		2 bytes	Complement check
;16	$00:FFDE		2 bytes	Checksum
;17 $00:FFE4		12 bytes Native vectors
;18	$00:FFF4		12 bytes Emulation vectors

.segment "EXTHEADER"
	.byte $05			; gamepak ram, 32KiB, no$sns seems to ignore this unless licensee code is $33
.segment "HEADER"		; $FFC0
    .byte ROM_NAME

.segment "ROMINFO"		; $FFD5 in file
    .byte $20			; Map mode, has to be slow lorom
    .byte $15			; Cart type, superfx ROM+RAM+battery
;Cartridgetype values:
;$01 ROM and RAM no SRAM, $02 ROM and SRAM. higher than $02 indicates special hardware addon in cartridge
;	$00	= ROM Only
;	$01	= ROM + RAM
;	$02	= ROM + RAM + BATTERY
;	For ROMs with an enhancement chip: $0*, $1*, $2*, $3*, $E*, $F* Which is: DSP, SuperFX, OBC1, SA-1, other, custom chip
;	higher than $02 indicates special hardware addon in cartridge,
;	$*3	= ROM + Enhancement Chip
;	$*4	= ROM + Enhancement Chip + RAM
;	$*5	= ROM + Enhancement Chip + RAM + BATTERY
;	$*6	= ROM + Enhancement Chip + SRAM(?)
;	Combining the two nibbles will give you different ROM types. If you want ROM + SuperFX chip, set byte to $13.
    .byte $08			; ROM size 256K
    .byte $00			; SRAM size 0 use gamepak ram for gsu
	.byte $01			; Region code, 0 Japan, 1 USA, 2 to 12 => PAL, $0F canada?
	.byte $33			; Licensee code, $33?
	.byte $00			; Version number
    .word $AAAA,$5555	; dummy checksum and complement

.segment "VECTORS" ;$FFE4, native vectors
    .word 0 ; cop
	.word 0 ; brk
	.word 0 ; abort
	.word nmiHandler ; nmi
	.word 0 ; unused
	.word $010E ;irqHandler ; irq
	
	;$FFF4, emulation mode vectors
	;cop, unused, abort, nmi, reset, irq
    .word 0, 0, 0, 0, 0, 0, Reset, 0


