AS = 64tass
ASFLAGS = -a --mw65c02

.PHONY: all runhex

all: bitmaps.hex

runhex: bitmaps.hex
	python $(FOENIXMGR)/FoenixMgr/fnxmgr.py --upload bitmaps.hex

%.hex: %.asm
	$(AS) $(ASFLAGS) --intel-hex -o $@ $<
