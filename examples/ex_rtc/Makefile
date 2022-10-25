AS = 64tass
ASFLAGS = -a --mw65c02

.PHONY: all runhex

all: rtc.hex

runhex: rtc.hex
	python $(FOENIXMGR)/FoenixMgr/fnxmgr.py --upload rtc.hex

%.hex: %.asm
	$(AS) $(ASFLAGS) --intel-hex -o $@ $<
