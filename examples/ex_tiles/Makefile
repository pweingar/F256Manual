AS = 64tass
ASFLAGS = -a --mw65c02

.PHONY: all runhex

all: tiles.hex

runhex: tiles.hex
	python $(FOENIXMGR)/FoenixMgr/fnxmgr.py --upload tiles.hex

%.hex: %.asm
	$(AS) $(ASFLAGS) --intel-hex -o $@ $<
