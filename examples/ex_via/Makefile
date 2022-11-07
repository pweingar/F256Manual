AS = 64tass
ASFLAGS = -a --mw65c02

.PHONY: all runhex

all: via.hex

runhex: via.hex
	python $(FOENIXMGR)/FoenixMgr/fnxmgr.py --upload via.hex

%.hex: %.asm
	$(AS) $(ASFLAGS) --intel-hex --list=via.lst --labels=via.lbl -o $@ $<
