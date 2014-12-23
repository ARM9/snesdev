// Based on blarggs ca65 spc700 demo

    arch snes.smp
include "../../../lib/spc700/regs.inc"
include "../../../lib/spc700/spc700_init.inc"

    //spc_zpage()
    origin 0
foo:; fill 5
bar:; fill 5

    //spc_code()
    origin 0
    base $200

constant TIMER_BPM(120)

// Base pitch of notes
constant BASE_HZ(570*10)
constant SAMPLES_PER_CYCLE(2) // number of samples in fundamental wave cycle
constant BASE_PITCH(BASE_HZ*10000/78125*SAMPLES_PER_CYCLE)

// Starts note with VPITCH=pitch for chan (0 through 7)
macro start_note(pitch, chan, inst) {
    ldy #{pitch}>>8
    lda #{pitch}
    ldx #{inst}
    phx
    ldx #{chan} * $10
    jsr init_note
    WDSP(DSP_KON, #1 << {chan})
}

main:
    clp
    jsr init_dsp

    // Have timer 0 tick at TIMER_BPM
    str REG_T0DIV=#(8000 + TIMER_BPM/2) / TIMER_BPM
    str REG_CONTROL=#$81    // enable IPL ROM and TIMER0

    // Start the three notes of major chord with some delay between each
    //start_note BASE_PITCH*4/4, 0, 3
    start_note((BASE_PITCH+100)*5/4, 2, 1)

    lda #100
    jsr delay_beats
    start_note((BASE_PITCH+140)*5/4, 2, 1)
    //start_note BASE_PITCH*5/4, 1, 2

    lda #100
    jsr delay_beats

    start_note((BASE_PITCH+180)*5/4, 2, 1)

_forever:
    bra _forever


// Initializes global DSP registers
init_dsp:
    WDSP(DSP_FLG,  #$20)
    WDSP(DSP_KON,  #0)
    WDSP(DSP_KOFF, #$FF)
    WDSP(DSP_DIR,  #directory>>8)

    WDSP(DSP_PMON,  #0)
    WDSP(DSP_KOFF,  #0)
    WDSP(DSP_NON,   #0)
    WDSP(DSP_EON,   #0)
    WDSP(DSP_MVOLL, #$7F)
    WDSP(DSP_MVOLR, #$7F)
    WDSP(DSP_EVOLL, #0)
    WDSP(DSP_EVOLR, #0)

    rts

// Moves data to x OR addr. X should be $00, $10 ... $70 to select the voice.
// Data can be #immediate or Y.
// Preserved: X, Y
macro dmovx(addr, data) {
    txa
    ora #{addr}
    ldy {data}
    stw REG_DSPADDR
}

macro dmovx(addr) {
    txa
    ora #{addr}
    stw REG_DSPADDR
}

// Initializes note on voice X ($00, $10 ... $70) with pitch YA
init_note:
    phy
    pha

    dmovx(DSP_VVOLL,  #$7F)
    dmovx(DSP_VVOLR,  #$7F)
    ply
    dmovx(DSP_VPITCHL)
    ply
    dmovx(DSP_VPITCHH)
    stx $00
    ply
    plx
    pla
    phx
    phy
    tay
    ldx $00
    dmovx(DSP_VSRCN)
    dmovx(DSP_VADSR1, #$CF)
    dmovx(DSP_VADSR2, #$28)
    dmovx(DSP_VGAIN,  #$CF)

    rts

// Delays A beats
// Preserved: Y
scope delay_beats: {
_loop:
    ldx REG_T0OUT
_wait_timer_tick:
    cpx REG_T0OUT
    beq _wait_timer_tick
    dec
    bne _loop
    rts
}

// Sample directory must be aligned to page
    align($100)
directory:

    dw 0, 0

    dw holdit, 0

brr_heap_start:
    insert holdit, "holdit.brr"

// vim:ft=bass
