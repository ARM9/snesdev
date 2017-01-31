
macro ColumnMajorMap(variable width, variable height, variable mode) {
    // check if multiple of 16 because we pad with 8x8 px tiles on all 4 sides
    if width%16 != 0 || height%16 != 0 {
        warning "ColumnMajorMap width or height NOT a multiple of 16!!"
    }
    constant max_cols(256/8)
    constant max_rows(224/8) // could theoretically have more with OBJ mode
    variable cols(width/8)
    variable rows(height/8)
    constant vert_padding((max_rows - rows))
    constant horiz_padding((max_cols - cols))
    variable map_size(cols*rows) // size in words
    
    if mode == 128 {
        constant x_inc($10) // increments for next column
    } else if mode == 160 {
        constant x_inc($14)
    } else {
        constant x_inc($18)
    }

    variable tile(%0000'0000'0000'0000)
    //             vhop ppcc cccc cccc
    constant blank_tile(%0001'0010'1010'0000) // uses palette 4
    //                   vhop ppcc cccc cccc
map_data{#}:
    // fill top rows
    variable i(max_cols*vert_padding/2)
    while i > 0 {
        dw blank_tile
        variable i(i-1)
    }

    variable i(map_size)
    variable y(0)
    while i > 0 {
        // fill left edge
        variable x(horiz_padding/2)
        while x > 0 {
            dw blank_tile
            variable x(x-1)
        }

        // framebuffer
        variable x(0)
        while x < cols {
            dw x*x_inc + y
            variable x(x+1)
            variable i(i-1)
        }

        // fill right edge
        variable x(horiz_padding/2)
        while x > 0 {
            dw blank_tile
            variable x(x-1)
        }
        variable y(y+1)
    }
    // fill bottom rows
    variable i(max_cols*vert_padding/2)
    while i > 0 {
        dw blank_tile
        variable i(i-1)
    }
    constant size(pc() - map_data{#})
}

// vim:ft=snes
