AS = 64tass
ASFLAGS = -a --mw65c02

.PHONY: all runhex

all: mmu_text.hex

runhex: mmu_text.hex
	python $(FOENIXMGR)/FoenixMgr/fnxmgr.py --upload mmu_text.hex

%.hex: %.asm
	$(AS) $(ASFLAGS) --intel-hex -o $@ $<
