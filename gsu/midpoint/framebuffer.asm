
    bss()
framebuffer_counter:;   fill 1
doublebuffer_index:;    fill 2

    sram0()
vbl_count:;             fill 2
framebuffer_status:;    fill 2

constant FRAMEBUFFER($702000)
constant FRAMEBUFFER_SIZE($5400) // is actually $6100 (should be $6000?), need to limit plotting to $5400 by limiting x to 224

constant VRAM_SCREEN1($0000)
constant VRAM_SCREEN2($3000)
constant VRAM_FB_MAP($2C00)

    bank0()
scope chugFramebuffer: {
    //a8
    //i16
    lda.b #GSU_GO_BIT
-;  bit.w GSU_SFR   // Wait for GSU to stop
    bne -

    stz.w GSU_SCMR

    rep #$20
    lda.l vbl_count
    inc
    sta.l vbl_count
    sep #$20

    ldy.w #FRAMEBUFFER_SIZE / 2

    and.b #1
    beq dma_fb_bottom
        // dma top of framebuffer
        ldx.w doublebuffer_index
        stx.w $2116
        lda.b #FRAMEBUFFER>>16
        ldx.w #FRAMEBUFFER
        jsr dma.to_vram
        lda.l framebuffer_status
        ora.b #1
        sta.l framebuffer_status

        bra dma_done
dma_fb_bottom:
        // dma bottom of framebuffer
        rep #$21
        lda.w doublebuffer_index
        adc.w #FRAMEBUFFER_SIZE / 4
        tax
        sep #$20
        stx.w $2116
        lda.b #FRAMEBUFFER>>16
        ldx.w #(FRAMEBUFFER + (FRAMEBUFFER_SIZE / 2))
        jsr dma.to_vram

        lda.l framebuffer_status
        and.b #~1
        sta.l framebuffer_status
        lda.w framebuffer_counter
        and.b #1
        beq set_bg12nba_screen2
            // swap buffer
            ldx.w #VRAM_SCREEN2
            stx.w doublebuffer_index
            lda.b #(VRAM_SCREEN1 >> 12)
            sta.w REG_BG12NBA
            bra +

set_bg12nba_screen2:
            ldx.w #VRAM_SCREEN1
            stx.w doublebuffer_index
            lda.b #(VRAM_SCREEN2 >> 12)
            sta.w REG_BG12NBA
+
    inc.w framebuffer_counter

dma_done:
    lda.w gsu_scmr_mirror
    sta.w GSU_SCMR
    lda.w GSU_SFR
    ora.b #GSU_GO_BIT
    sta.w GSU_SFR

    rts
}

// vim: ft=bass
