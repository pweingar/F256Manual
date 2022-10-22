AS = 64tass
ASFLAGS = -a --mw65c02

.PHONY: all runhex

all: psg.hex

runhex: psg.hex
	python3 $(FOENIXMGR)/FoenixMgr/fnxmgr.py --upload psg.hex

%.hex: %.asm
	$(AS) $(ASFLAGS) --intel-hex -o $@ $<
