AS = 64tass
ASFLAGS = -a --mw65c02

.PHONY: all runhex

all: sol.hex

runhex: sol.hex
	python $(FOENIXMGR)/FoenixMgr/fnxmgr.py --upload sol.hex

%.hex: %.asm
	$(AS) $(ASFLAGS) --intel-hex --list=sol.lst --labels=sol.lbl -o $@ $<
