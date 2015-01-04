
    bss()
scope Camera: {
x:; dw 0// [CI] horizontal
y:; dw 0// [CI] depth
z:; dw 0// [CI] vertical
Lfe:; dw 0// [U] Distance between base point and viewpoint (Sets screen-sprite ratio)
Les:; dw 0// [U] fov, Distance between viewpoint and screen (the effect of screen angle considered; screen horizontal distance 256)
Aas:; dw 0// [A] Azimuth angle, rotation around Y axis
Azs:; dw 0// [A] Zenith angle, X/Z rotationish
cx:; dw 0//\ [CI] focal point
cy:; dw 0///
raster_center:; dw 0 // [I]
horizon:; dw 0 // [I]
}

    bank0()
scope Camera {

constant OFFSET_CX(-128)
constant OFFSET_CY(-112)

scope init: {
    php
    rep #$30

    lda.w #$20
    sta.l Camera.Lfe
    lda.w #$20
    sta.l Camera.Les
    lda.w #$6000 // rotation around Y axis
    sta.l Camera.Aas
    lda.w #$3f00
    sta.l Camera.Azs

    plp
    rts
}

scope update: {
    php

    rep #$30

    lda.w Player.x
    sta.w Camera.x

    lda.w Player.y
    sta.w Camera.y

    lda.w Player.z
    sta.w Camera.z

    lda.w Player.y_rot
    sta.w Camera.Aas

    lda.w Camera.cy
    bmi +
    lsr #4
    bra ++
+
    sec; ror
    sec; ror
    sec; ror
    sec; ror
+
    sta.w Camera.cy
    tay
    lda.w Camera.cx
    bmi +
    lsr #4
    bra ++
+
    sec; ror
    sec; ror
    sec; ror
    sec; ror
+
    sta.w Camera.cx

    plp
    rts
}

//call during nmi
scope writePpu: {
    php
    rep #$30
    
    lda.w Camera.cx

    sep #$20
    sta.w REG_M7X
    xba
    sta.w REG_M7X
    xba
    rep #$21
    adc.w #OFFSET_CX
    sep #$20
    sta REG_BG1HOFS
    xba
    sta REG_BG1HOFS

    rep #$20
    lda.w Camera.cy
    sep #$21 // set carry for "free"
    sta.w REG_M7Y
    xba
    sta.w REG_M7Y
    xba
    rep #$20
    sbc.w Camera.raster_center
    clc
    adc.w #OFFSET_CY
    sep #$20
    sta.w REG_BG1VOFS
    xba
    sta.w REG_BG1VOFS

    plp
    rts
}
}
// vim:ft=bass
