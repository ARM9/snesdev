EMU	:= $(DEVKITPRO)/emulators/snes

ASFLAGS	:= -benchmark -create
#DEBUG	:= 1

higan-p		:= $(EMU)/../higan/higan-performance
higan-b		:= $(EMU)/../higan/higan-balanced
higan-a		:= $(EMU)/../higan/higan-accuracy
bsnes		:= $(EMU)/bsnes/bsnes
ifeq ($(OS),Windows_NT)
snes9x		:= $(EMU)/snes9x/snes9x-x64
else
snes9x		:= $(EMU)/snes9x/snes9x-gtk
endif

TARGET	:= $(shell basename $(CURDIR))
OUTPUT	:= $(CURDIR)/$(TARGET).sfc

ifneq ($(DEBUG),)
ASFLAGS	+= -d DEBUG=1
endif

ASFLAGS	+= -d ROM_NAME=$(TARGET).sfc -sym $(TARGET).sym -o $(TARGET).sfc

#------------------------------------------------
.PHONY: all clean run

all: gfx
	bass $(ASFLAGS) main.asm

clean: clean-gfx
	rm -rf $(OUTPUT)

debug: all
	$(bsnes) $(OUTPUT)

run: all
	$(snes9x) $(OUTPUT)

run2: all
	$(higan-a) $(OUTPUT)

#include gfx/makefile
