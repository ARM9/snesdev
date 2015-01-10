export PATH	:= $(DEVKITSNES)/bass/bass/:$(PATH)
export EMU	:= $(DEVKITPRO)/emulators/snes

ASFLAGS		:= -benchmark -create
SPCFLAGS	:= -create -o main.spc
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
export OUTPUT	:= $(CURDIR)/$(TARGET).sfc

ifneq ($(DEBUG),)
ASFLAGS		+= -d DEBUG=1
SPCFLAGS	+= -d DEBUG=1
endif

ASFLAGS	+= -d ROM_NAME=$(TARGET).sfc -o $(TARGET).sfc

#------------------------------------------------
.PHONY: clean run

all:
	bass $(SPCFLAGS) spc/main.asm
	bass $(ASFLAGS) main.asm

clean:
	rm -rf $(OUTPUT)

debug: all
	$(bsnes) $(OUTPUT)

run: all
	$(snes9x) $(OUTPUT)

run2: all
	$(higan-a) $(OUTPUT)

