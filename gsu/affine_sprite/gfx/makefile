export PATH	:= $(DEVKITSNES)/tools/:$(PATH)

PNGFILES	:= $(wildcard gfx/*.png)
SPRITES		:= $(PNGFILES:.png=.img.bin) $(PNGFILES:.png=.pal.bin)

%.img.bin %.pal.bin : %.png %.grit
	snesgrit $< -ff$(<:.png=.grit) -ftb -fa -fh! -o$*

.PHONY: gfx clean-gfx

gfx: $(SPRITES)
	

clean-gfx:
	rm -f $(SPRITES)

