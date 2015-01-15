
//void dspObjectProjection(unsigned int x, unsigned int y, unsigned int z, unsigned int *H, unsigned int *V, unsigned int *M)//
dspObjectProjection:
    php
    sep #$20
    //lda.b #DSP_BANK
    //pha
    //plb

    //lda.b #$06 // Command for object projection, standard 6 cycles
    //sta.l REG_DSP_DATA

    plp
    rts

// vim:ft=snes
