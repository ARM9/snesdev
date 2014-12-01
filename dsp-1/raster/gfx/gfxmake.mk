
export GFX	:=	$(CURDIR)/gfx

gfx:
	$(GFXCONV) -n -m7 -gp -pc128 -po32 -fpcx $(GFX)/koop.pcx
