
.rodata
egg:
	.incbin "../gfx/egg.bin"
egg_size = *-egg

tile:
	.incbin "../gfx/tile.bin"
tile_size = *-tile

.segment "BANK3" : far
lake_pal:
	.incbin "../gfx/lake.pal"
lake_pal_size = *-lake_pal

lake:
	.incbin "../gfx/lake.bin", $A000, $3000*2
lake_size = *-lake

