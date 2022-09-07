# Example: MMU and Text

A simple example showing the basics of using the MMU and the text screen on the JUNIOR

## Building

To build the example code, you will need 64TASS and Make (unless you want to build it by hand).

To build an Intel HEX file run `make mmu_text.hex`.

## Running

If you have the FoenixMgr installed and configured on your system, you can send the HEX file to JUNIOR using the command:

```
make runhex
```

NOTE: the HEX file assumes that the RESET vector at $FFFC is in RAM. If the current memory configuration of the JUNIOR has flash mapped there, you will need to manually start execution at $1000 using whatever code is running on the JUNIOR at the time.
