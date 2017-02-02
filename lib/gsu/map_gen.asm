
// ColumnMajorMap creates a map for a superfx 2/4/8bpp framebuffer (NOT OBJ MODE)
// Map assumes framebuffer tiles start at base+0x0000
// 
// width: map width in pixels
// height: map height in pixels
// bpp: bits per pixel, used to calculate vram offsets
// palette: palette used for framebuffer (0-7), in direct color mode this corresponds to extra rgb bits
// blank_addr: map entry for tile used for letterboxing
// blank_pal: palette number for blank tile
macro ColumnMajorMap(width, height, bpp, palette, blank_addr, blank_pal) {
    // check if multiple of 16 because we pad with 8x8 px tiles on all 4 sides
    if {width}%16 != 0 || {height}%16 != 0 {
        warning "ColumnMajorMap width or height NOT a multiple of 16!!"
    }

    constant max_cols(256/8)
    constant max_rows(224/8)
    variable cols({width}/8)
    variable rows({height}/8)
    constant vert_padding((max_rows - rows))
    constant horiz_padding((max_cols - cols))
    variable map_size(cols*rows) // size in words

    // set map column increment
    if {height} <= 128 {
        constant x_inc($10) // 128
    } else if {height} <= 160 {
        constant x_inc($14) // 160
    } else if {height} <= 192 {
        constant x_inc($18) // 192
    } else {
        warning "Invalid height for ColumnMajorMap: "
        print {height}
        print "\n"
        constant x_inc($18) // 192
    }

    // map format: vhop ppcc cccc cccc
    variable blank_tile(({blank_addr}/{bpp}/8) | ({blank_pal}<<10))
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
            dw (x*x_inc + y) | ({palette}<<10)
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
