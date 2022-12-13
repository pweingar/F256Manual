AS = 64tass
ASFLAGS = -a --mw65c02

.PHONY: all runhex

all: dma.hex

runhex: dma.hex
	python $(FOENIXMGR)/FoenixMgr/fnxmgr.py --upload dma.hex

%.hex: %.asm
	$(AS) $(ASFLAGS) --intel-hex -o $@ $<
