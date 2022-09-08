AS = d:\64tass\64tass
ASFLAGS = -a --mw65c02

.PHONY: all runhex

all: bitmaps.hex

runhex: mmu_text.hex
	python3 $(FOENIXMGR)/FoenixMgr/fnxmgr.py --upload bitmaps.hex

%.hex: %.asm
	$(AS) $(ASFLAGS) --intel-hex -o $@ $<
