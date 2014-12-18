    arch snes.cx4

db "cx4"
cx4_start:
    nop
    stop
    invalid0
    jmp $7f
    finish ext_dta
    //skipnc
    call
    ret
    inc ext_ptr
    invalid4
// vim:ft=bass
