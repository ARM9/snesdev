export PATH	:= $(DEVKITSNES)/bass/bass/:$(PATH)
export EMU	:= $(DEVKITPRO)/emulators/snes

ASFLAGS	:= -benchmark -create
#DEBUG	:= 1

higan-p		:= $(EMU)/../higan/higan-performance
higan-b		:= $(EMU)/../higan/higan-balanced
higan-a		:= $(EMU)/../higan/higan-accuracy
bsnes		:= $(EMU)/bsnes/bsnes
ifeq ($(OS),Windows_NT)
prevdir		= $(CURDIR)
snes9x		:= $(EMU)/snes9x/snes9x-x64
ASFLAGS		+= -d _DEVNULL="NUL"
else
snes9x		:= $(EMU)/snes9x/snes9x-gtk
ASFLAGS		+= -d _DEVNULL="/dev/null"
endif

TARGET	:= $(shell basename $(CURDIR))
export OUTPUT	:= $(CURDIR)/$(TARGET).sfc

ifneq ($(DEBUG),)
ASFLAGS	+= -d DEBUG=1
endif

ASFLAGS	+= -d ROM_NAME=$(TARGET).sfc -o $(TARGET).sfc

#------------------------------------------------
.PHONY: clean run

all:
	bass $(ASFLAGS) main.asm

clean:
	rm -rf $(OUTPUT)

debug: all
	$(bsnes) $(OUTPUT)

run: all
	$(snes9x) $(OUTPUT)

run2: all
	$(higan-a) $(OUTPUT)
