AS = 64tass
ASFLAGS = -a --mw65c02

.PHONY: all runhex

all: interrupts.hex

runhex: interrupts.hex
	python $(FOENIXMGR)/FoenixMgr/fnxmgr.py --upload interrupts.hex

%.hex: %.asm
	$(AS) $(ASFLAGS) --intel-hex -o $@ $<
