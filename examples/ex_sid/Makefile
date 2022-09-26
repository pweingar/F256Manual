AS = 64tass
ASFLAGS = -a --mw65c02

.PHONY: all runhex

all: sid.hex

runhex: sid.hex
	python3 $(FOENIXMGR)/FoenixMgr/fnxmgr.py --upload sid.hex

%.hex: %.asm
	$(AS) $(ASFLAGS) --intel-hex -o $@ $<
