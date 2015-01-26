if !{defined _MEM_INC} {
define _MEM_INC(1)

macro BlockMoveP(src, dest, size) {
    //a16
    //i16
    ldx.w #{src}
    ldy.w #{dest}
    lda.w #{size}-1
    mvp ({dest}>>16)=({src}>>16)
}

macro BlockMoveN(src, dest, size) {
    //a16
    //i16
    ldx.w #{src}
    ldy.w #{dest}
    lda.w #{size}-1
    mvn ({dest}>>16)=({src}>>16)
}

}
// vim:ft=snes
