AS = 64tass
ASFLAGS = -a --mw65c02

.PHONY: all runhex

all: timers.hex

runhex: timers.hex
	python $(FOENIXMGR)/FoenixMgr/fnxmgr.py --upload timers.hex

%.hex: %.asm
	$(AS) $(ASFLAGS) --intel-hex -o $@ $<
