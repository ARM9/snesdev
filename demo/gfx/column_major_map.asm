
scope column_major_map: {
    variable map_size($400)
    variable tile0($1800)
    constant blank_tile($12a0)

    while map_size > $3c0 {
        dw $02a1
        variable map_size(map_size-1)
    }
    while map_size > $c1 {
        dw blank_tile
        dw blank_tile
        variable map_size(map_size-2)
        variable x(28)
        variable t_tile0(tile0)
        while x > 0 {
            dw t_tile0
            variable t_tile0(t_tile0+24)
            variable x(x-1)
            variable map_size(map_size-1)
        }
        variable tile0(t_tile0-671)
        dw blank_tile
        dw blank_tile
        variable map_size(map_size-2)
    }
    while map_size > 0 {
        dw $02a1
        variable map_size(map_size-1)
    }
    constant size(pc() - column_major_map)
}

// vim:ft=snes
