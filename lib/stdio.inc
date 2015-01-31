
if !{defined _STDIO_INC} {
define _STDIO_INC(1)

include "dma.inc"
include "ppu.inc"

macro PrintString(str_ptr) {
    //a8
    //i16
    lda.b #{str_ptr}>>16
    ldx.w #{str_ptr}
    jsr stdout.write_string
}

macro PrintString(str_ptr, column, row) {
    //a8
    //i16
    rep #$20
    stdout.SetXY({column}, {row})
    sep #$20
    lda.b #{str_ptr}>>16
    ldx.w #{str_ptr}
    jsr stdout.write_string
}

macro PrintString(str_ptr, column, row, palette) {
    //a8
    //i16
    rep #$20
    stdout.SetXY({column}, {row})
    stdout.SetPalette({palette})
    sep #$20
    lda.b #{str_ptr}>>16
    ldx.w #{str_ptr}
    jsr stdout.write_string
}

macro puts(string) {
    //a8
    //i16
    phk
    jsr stdout.write_string_retaddr
    db {string}, 0
}

    bank0()
scope stdout {

macro Init(bg_num, palette, prio) {
    //a8
    rep #$20

    // reset stdout vram map properties
    // palette
    lda.w #$0000
    if (({palette} != 0) || ({prio} != 0)) {
        sta.l stdout.wram_buffer_pointer
        lda.w #(({palette} & 7) << 10) | ({prio} << 13)
        sta.l stdout.vram_map_properties
    } else {
        sta.l stdout.vram_map_properties
    }

    sep #$20
    lda.b #{bg_num}
    jsr stdout.initBackground
    //PPU.InitBg({bg_num}, stdout.VRAM_MAP_ADDR, stdout.VRAM_TILES_ADDR)
}

macro InitBg(bg_num) {
    //a8
    //i16
    lda.b #{bg_num}
    jsr stdout.initBackground
}

    // set up map & tile ppu properties
scope initBackground: {
//returns: void
//args:
//  a8 = bg number
    //a8
    phx; php
    rep #$30

    dec
    and.w #$0007 //1-4
    asl
    tax
    sep #$20
    lda.b #((stdout.VRAM_MAP_ADDR >> 8) & $FC)

    jmp (_jtable0,x)
_jtable0:
dw L0
dw L1
dw L2
dw L3
L0:
    sta.w bg1sc_mirror
    lda.b #((stdout.VRAM_TILES_ADDR >> 12) & $0F)
    tsb.w bg12nba_mirror
    lda.b #%0001
    bra +
L1:
    sta.w bg2sc_mirror
    lda.b #((stdout.VRAM_TILES_ADDR >> 12) & $0F) << 4
    tsb.w bg12nba_mirror
    lda.b #%0010
    bra +
L2:
    sta.w bg3sc_mirror
    lda.b #((stdout.VRAM_TILES_ADDR >> 12) & $0F)
    tsb.w bg34nba_mirror
    lda.b #%0100
    bra +
L3:
    sta.w bg4sc_mirror
    lda.b #((stdout.VRAM_TILES_ADDR >> 12) & $0F) << 4
    tsb.w bg34nba_mirror
    lda.b #%1000
+
    tsb.w tm_mirror

    plp; plx
    rts
}

// supported control characters:
//  \n = 0x0A
scope write_string: {
//returns:
//  y16 = string length
//args:
//  a8  = pointer to text bank byte
//  x16 = pointer to text
//zeropage:
//  zp0 and zp1  = pointer to text for indirect long addressing
    phb
    php
    stx.b zp0
    sta.b zp1
    
    lda.b #stdout.wram_buffer>>16
    pha; plb

    rep #$20
    ldx.w stdout.wram_buffer_pointer
    ldy.w #-1
_next:
    cpx.w #WRAM_BUFFER_SIZE
    bcs _wrap
-
    iny
    lda [zp0],y
    and.w #$00FF
    beq _end

    cmp.w #$000A
    beq _line_feed

    sec
    sbc.w #32
    ora.w stdout.vram_map_properties
    sta.w stdout.wram_buffer,x
    inx
    inx
    bra _next

_line_feed:
    txa
    and.w #$FFC0
    clc
    adc.w #64
    tax
    bra _next

_wrap:
    ldx.w #$0000
    bra -

_end:
    stx.w stdout.wram_buffer_pointer

    plp
    inc
    sta.w wram_buffer_dirty

    plb
    rts
}

scope write_string_retaddr: {
//returns: void
//args:
//
    //a8
    //i16
    plx // pull return address
    pla // pull bank of string, arg for write_string
    php
    inx // return address+1 = start of string
    phx // save on stack
    jsr stdout.write_string
    plx
    rep #$31
    txa
    sty.b zp0 // string length + string address = return address
    adc.b zp0
    tax
    plp

    phx // store real return address
    rts
}

scope clearWramBuffer: {
    //a8
    //i16
    php
    rep #$10; sep #$20
    lda.b #0
    sta.l stdout.wram_buffer_pointer
    sta.l stdout.wram_buffer_pointer + 1
    FillWram(CONST_ZERO, stdout.wram_buffer, stdout.WRAM_BUFFER_SIZE)
    plp
    rts
}

scope dmaWramBufferToVram: {
    //a8
    //i16
    php
    rep #$10; sep #$20
    lda.l stdout.wram_buffer_dirty
    beq _end
    {
    lda.b #0
    sta.l stdout.wram_buffer_pointer
    sta.l stdout.wram_buffer_pointer + 1
    sta.l stdout.wram_buffer_dirty
    
    LoadVram(stdout.wram_buffer, VRAM_MAP_ADDR, stdout.WRAM_BUFFER_SIZE)
    }
_end:
    plp
    rts
}

macro SetXY(column, row) {
    //a16
    lda.w #(({row}<<6) + ({column}<<1)) & $FFFE
    sta.l stdout.wram_buffer_pointer
}

macro SetMapProperties(palette, prio) {
    //a16
    lda.w #(({palette} & 7) << 10) | ({prio} << 13)
    // priority
    sta.l stdout.vram_map_properties
}

macro SetPalette(palette) {
    //a16
    lda.l stdout.vram_map_properties
    and.w #~(7 << 10)
    if ({palette} != 0) {
    ora.w #(({palette} & 7) << 10)
    }
    sta.l stdout.vram_map_properties
}

macro SetMapPriority(prio) {
    //a16
    lda.l stdout.vram_map_properties
    and.w #~(1 << 13)
    if ({prio} != 0) {
    ora.w #{prio} << 13
    }
    sta.l stdout.vram_map_properties
}

}

    loram()
scope stdout {
    constant WRAM_BUFFER_SIZE($700)

    wram_buffer_dirty:; fill 1
    wram_buffer:; fill WRAM_BUFFER_SIZE
    wram_buffer_pointer:; fill 2
    vram_map_properties:; fill 2

    constant VRAM_MAP_ADDR($7400)
    constant VRAM_TILES_ADDR($7000)
}

    bank0()
scope stdlib {
int_to_string:
//returns: void
//args:
//  a16 = integer to convert
//  x16 = pointer to destination string
//  y16 = bank byte of pointer to dest string
    //a16
    //i16
    php

    stx.b zp0
    sty.b zp1

    tax
    ldy.w #4
    sep #$20
    lda.b #0
    sta [zp0],y
    dey

    txa
_next:
    and.b #$0F
    cmp.b #$0A
    bcc _is_dec
    clc
    adc.b #23+32
    bra +
_is_dec:
    adc.b #16+32
+
    sta [zp0],y
    rep #$20
    txa
    lsr #4
    tax
    sep #$20
    dey
    bpl _next

    plp
    rts
}

macro scope itoa(str_ptr) {
    //a16
    //i16
    ldx.w #{str_ptr}
    ldy.w #{str_ptr}>>16
    jsr stdlib.int_to_string
}

}
// vim:ft=snes
