
bgmode_hdma:
db 32, $00 // 32 lines of mode 0
db 96, $07 // 96 lines of mode 7
db 96, $09 // 96 lines of mode 1
db $00

tm_hdma:
db 32, $1C // sprites, bg4, bg3
db 96, $11 // sprites, bg1
db 96, $00 // 
db $00

// vim:ft=bass
