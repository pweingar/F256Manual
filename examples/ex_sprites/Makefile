AS = 64tass
ASFLAGS = -a --mw65c02

.PHONY: all runhex

all: sprites.hex

runhex: sprites.hex
	python $(FOENIXMGR)/FoenixMgr/fnxmgr.py --upload sprites.hex

%.hex: %.asm
	$(AS) $(ASFLAGS) --intel-hex -o $@ $<
