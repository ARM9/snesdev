; ROM header including interrupt vectors

.define ROM_TITLE "SA-1 test by ARM9"

; Size predefs for ROM/RAM/SRAM fields
SIZE_NONE	= $00
SIZE_2KiB	= $01 ; amount of cart RAM in Super Mario World
SIZE_4KiB	= $02
SIZE_8KiB	= $03
SIZE_16KiB	= $04
SIZE_32KiB	= $05 ; Amount of cart RAM in Mario Paint
SIZE_64KiB	= $06 ; Amount of cart RAM in Stunt Race FX
SIZE_128KiB	= $07 ; Amount of cart RAM in Dezaemon - Kaite Tsukutte Asoberu
SIZE_256KiB	= $08
SIZE_512KiB	= $09 ; Amount of ROM in Super Mario World
SIZE_1MiB	= $0A ; Amount of ROM in Mario Paint
SIZE_2MiB	= $0B ; Amount of ROM in Super Mario World 2
SIZE_4MiB	= $0C ; Amount of ROM in Donkey Kong Country 2 and 3
; Valid range for ROM: $08-$0C, most emulators don't mind $05
; Valid range for cart RAM: $00-$07

; Map modes
MODE_20		= $20 ; LoROM
MODE_21		= $21 ; HiROM
MODE_23		= $23 ; SA-1 ROM
MODE_25		= $25 ; ExHiROM + SlowROM
MODE_30		= $30 ; LoROM + FastROM
MODE_31		= $31 ; HiROM + FastROM
MODE_35		= $35 ; ExHiROM + FastROM

; Cartridge types
CART_ROM			= $00 ; ROM only
CART_ROM_RAM		= $01 ; ROM+RAM
CART_ROM_RAM_BAT	= $02 ; ROM+RAM+Battery
; Coprocessors (add with one of the above)
CART_DSP1			= $03 ; DSP-1
CART_GSU			= $13 ; SuperFX
CART_OBC1			= $23 ; OBC-1
CART_SA1			= $33 ; SA-1
CART_OTHER			= $E3	; \ Todo: determine out how/if emulators use these
CART_CUSTOM			= $F3	; | to distinguish between obscure stuff like the
							; / CX4, ST-0018, SPC7110 etc.

; Destination codes, most emulators use this to determine PAL/NTSC
DEST_JAPAN			= $00
DEST_USA_CANADA		= $01
DEST_EUROPE			= $02
DEST_SCANDANAVIA	= $03
DEST_FRENCH_EUROPE	= $06
DEST_DUTCH			= $07
DEST_SPANISH		= $08
DEST_GERMAN			= $09
DEST_ITALIAN		= $0A
DEST_CHINESE		= $0B
DEST_KOREAN			= $0D
DEST_COMMON			= $0E
DEST_CANADA			= $0F
DEST_BRAZIL			= $10
DEST_AUSTRALIA		= $11

.segment "HEADER"			; $FFB0
	.byte 0, 0				; B0 - Maker code
	.byte "ARM9"			; B2 - Game code
	.byte 0, 0, 0, 0, 0, 0, 0 ; B6 - 7 byte filler
	.byte SIZE_NONE		; BD - Ext cart RAM (for GSU), 32KiB, no$sns seems to ignore this unless licensee code is $33
	.byte 0					; BE - Special version(?)
	.byte 0					; BF - Cartridge sub-number(?)
    .byte ROM_TITLE			; C0 - Game title
.segment "ROMINFO"
    .byte MODE_23			; D5 - Map mode
    .byte CART_SA1+CART_ROM_RAM_BAT	; D6 - Cart type
    .byte SIZE_256KiB		; D7 - ROM size
    .byte SIZE_32KiB		; D8 - Cart RAM size
	.byte DEST_USA_CANADA	; D9 - Destination code (NTSC/PAL)
	.byte $33				; DA - Licensee code, $33?
	.byte $00				; DB - Version number (1.xx)
    .word $AAAA,$5555		; DC - dummy checksum and complement
;------------------------------------------------
.segment "VECTORS" 
;$FFE4, native vectors
	WRAM_NMI_VECTOR = $00F2
	WRAM_IRQ_VECTOR = $00F6
    .word 0					; cop
	.word 0					; brk
	.word 0					; abort
	.word WRAM_NMI_VECTOR	; nmi
	.word 0					; unused
	.word WRAM_IRQ_VECTOR	; irq
	.word 0, 0				; -
;$FFF4, emulation mode vectors
    .word 0					; cop
	.word 0					; unused
	.word 0					; abort
	.word 0					; nmi
	.word _Reset			; reset
	.word 0					; irq

