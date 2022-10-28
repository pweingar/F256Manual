AS = 64tass
ASFLAGS = -a --mw65c02

.PHONY: all runhex

all: tiles8.hex

runhex: tiles8.hex
	python $(FOENIXMGR)/FoenixMgr/fnxmgr.py --upload tiles8.hex

%.hex: %.asm
	$(AS) $(ASFLAGS) --intel-hex -o $@ $<
