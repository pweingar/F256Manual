;;;
;;; Registers for DMA
;;;

DMA_CTRL = $DF00                ; DMA Control Register
DMA_CTRL_START = $80            ; Start the DMA operation
DMA_CTRL_INT_EN = $08           ; Enable DMA interrupts
DMA_CTRL_FILL = $04             ; DMA is a fill operation (otherwise DMA is a copy)
DMA_CTRL_2D = $02               ; DMA is 2D operation (otherwise it is 1D)
DMA_CTRL_ENABLE = $01           ; DMA engine is enabled

DMA_STATUS = $DF01              ; DMA status register (Read Only)
DMA_STAT_BUSY = $80             ; DMA engine is busy with an operation

DMA_FILL_VAL = $DF01            ; Byte value to use for fill operations

DMA_SRC_ADDR = $DF04            ; Source address (system bus) for copy operations
DMA_DST_ADDR = $DF08            ; Destination address (system bus) for fill and copy operations

DMA_COUNT = $DF0C               ; Number of bytes to fill or copy (1D operations, 24 bit value)
DMA_WIDTH = $DF0C               ; Width of rectangle to fill or copy (2D operations, 16 bit value)
DMA_HEIGHT = $DF0E              ; Height of rectangle to fill or copy (2D operations, 16 bit value)
DMA_STRIDE_SRC = $DF10          ; Width of the source bitmap image in bytes (2D operations, 16 bit value)
DMA_STRIDE_DST = $DF12          ; Width of the destination bitmap image in bytes (2D operations, 16 bit value)
