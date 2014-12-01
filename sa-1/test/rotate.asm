;;====================================;;
;; SA-1 32x32 Rotation Routine
;;====================================;;

;;====================================;;
;; How to Use:
;; 1. Put Graphics in !Source
;; 2. JSR to SUB_ROTATE
;; 3. Update contents of !DestBWRAM
;; to VRAM using CDMA Type #1, 4BPP,
;; 32 horizontal, 512 bytes.
;;====================================;;

.segment "BANK2"

;Notes:
;	Wait cycle when destination address of branch instruction is odd.
;	BRA always seems to have a wait cycle penalty (or did they mean that it always takes branch cycle?), stacks with ^ ???
;	wait cycle when data is read from rom or bwram.

.proc SUB_ROTATE

;; Destination BW-RAM "Virtual RAM" & BW-RAM
DestVRAM = $604000		; Dest VRAM is same as BWRAM, but each byte is 4-bits only.
				; i.e $40:0000 = $60:0000 | ($60:0001 << 4)
DestBWRAM = $402000

;; RAM Definitions
Degrees = $406000 ; #$00 to #$FF ($00 = 0 degrees)
Scale = $406001 ; #$0000 to #$7FFF ($0100 = 100%)

;; Stracth RAM
cosT = $04
sinT = $06
rowX = $08
rowY = $0A
tX = $0C
tY = $0E
Pointer = $10

;=====================
	PHP
	PHD
	REP #$30			;| 16-bit AXY
	LDA #$3100
	TCD
	
	LDA Degrees			;\ Calculate
	AND #$00FF			;| Cos & Sin values
	ASL				;|
	TAX				;|
	LDA CosTable,X		;|
	STA cosT			;|
	TXA				;|
	CLC				;|
	ADC #$0180			;|	
	AND #$01FE			;|
	TAX				;|
	LDA CosTable,X		;|
	STA sinT			;/
	
	STZ $2250			; scale cos/sin
	LDA Scale
	STA $2251
	LDA cosT
	STA $2253
	NOP
	LDY sinT
	LDA $2307
	STA cosT
	STY $2253
	NOP
	BRA :+
:	LDA $2307
	STA sinT
	
	LDA #$FFF0			; center and correct starting X/Y position
	STA $2251
	LDA cosT
	STA $2253
	NOP
	LDY sinT
	LDA $2306
	STA rowX
	STA rowY
	STY $2253
	NOP
	BRA :+
:	LDA $2306
	CLC
	ADC rowX
	CLC
	ADC #$1000
	SEC
	SBC cosT
	STA rowX
	STA tX
	LDA rowY
	SEC
	SBC $2306
	CLC
	ADC #$1000
	CLC
	ADC sinT
	STA rowY
	STA tY
	
	STZ Pointer			; Clear source bitmap pointer
	
	SEP #$10			; XY 8-bit
	
	PHB
	LDX #$40
	PHX
	PLB
	
	STZ $02
	
	LDY #$1F
@Y_Loop:
	STY $1F
	LDY #$1F
@X_Loop:
	LDA tX
	CLC
	ADC cosT
	STA tX
	
	CMP #$2000
	BCS @contX_Loop1
	AND #$FF00
	STA $00

	LDA tY
	SEC
	SBC sinT
	STA tY
	
	CMP #$2000
	BCS @contX_Loop2
	AND #$FF00
	LSR
	LSR
	LSR
	ADC $01
	REP #$10
	TAX
	SEP #$20
	LDA $3000,x ;$403000
	LDX Pointer
	STA DestVRAM,X
	SEP #$10
	REP #$20

@contX_Loop2:
	INC Pointer
	DEY
	BPL @X_Loop
	LDY $1F
	
	LDA rowX
	CLC
	ADC sinT
	STA rowX
	STA tX
	
	LDA rowY
	CLC
	ADC cosT
	STA rowY
	STA tY
	
	DEY
	BPL @Y_Loop
	
	SEP #$30
	
	PLB
	PLD
	PLP
	
	RTS

@contX_Loop1:
	LDA tY
	SBC sinT
	STA tY
	BRA @contX_Loop2


CosTable:
.word $0100,$0100,$0100,$00FF,$00FF,$00FE,$00FD,$00FC,$00FB,$00FA,$00F8,$00F7,$00F5,$00F3,$00F1,$00EF
.word $00ED,$00EA,$00E7,$00E5,$00E2,$00DF,$00DC,$00D8,$00D5,$00D1,$00CE,$00CA,$00C6,$00C2,$00BE,$00B9
.word $00B5,$00B1,$00AC,$00A7,$00A2,$009D,$0098,$0093,$008E,$0089,$0084,$007E,$0079,$0073,$006D,$0068
.word $0062,$005C,$0056,$0050,$004A,$0044,$003E,$0038,$0032,$002C,$0026,$001F,$0019,$0013,$000D,$0006
.word $0000,$FFFA,$FFF3,$FFED,$FFE7,$FFE1,$FFDA,$FFD4,$FFCE,$FFC8,$FFC2,$FFBC,$FFB6,$FFB0,$FFAA,$FFA4
.word $FF9E,$FF98,$FF93,$FF8D,$FF87,$FF82,$FF7C,$FF77,$FF72,$FF6D,$FF68,$FF63,$FF5E,$FF59,$FF54,$FF4F
.word $FF4B,$FF47,$FF42,$FF3E,$FF3A,$FF36,$FF32,$FF2F,$FF2B,$FF28,$FF24,$FF21,$FF1E,$FF1B,$FF19,$FF16
.word $FF13,$FF11,$FF0F,$FF0D,$FF0B,$FF09,$FF08,$FF06,$FF05,$FF04,$FF03,$FF02,$FF01,$FF01,$FF00,$FF00
.word $FF00,$FF00,$FF00,$FF01,$FF01,$FF02,$FF03,$FF04,$FF05,$FF06,$FF08,$FF09,$FF0B,$FF0D,$FF0F,$FF11
.word $FF13,$FF16,$FF19,$FF1B,$FF1E,$FF21,$FF24,$FF28,$FF2B,$FF2F,$FF32,$FF36,$FF3A,$FF3E,$FF42,$FF47
.word $FF4B,$FF4F,$FF54,$FF59,$FF5E,$FF63,$FF68,$FF6D,$FF72,$FF77,$FF7C,$FF82,$FF87,$FF8D,$FF93,$FF98
.word $FF9E,$FFA4,$FFAA,$FFB0,$FFB6,$FFBC,$FFC2,$FFC8,$FFCE,$FFD4,$FFDA,$FFE1,$FFE7,$FFED,$FFF3,$FFFA
.word $0000,$0006,$000D,$0013,$0019,$001F,$0026,$002C,$0032,$0038,$003E,$0044,$004A,$0050,$0056,$005C
.word $0062,$0068,$006D,$0073,$0079,$007E,$0084,$0089,$008E,$0093,$0098,$009D,$00A2,$00A7,$00AC,$00B1
.word $00B5,$00B9,$00BE,$00C2,$00C6,$00CA,$00CE,$00D1,$00D5,$00D8,$00DC,$00DF,$00E2,$00E5,$00E7,$00EA
.word $00ED,$00EF,$00F1,$00F3,$00F5,$00F7,$00F8,$00FA,$00FB,$00FC,$00FD,$00FE,$00FF,$00FF,$0100,$0100

.endproc

