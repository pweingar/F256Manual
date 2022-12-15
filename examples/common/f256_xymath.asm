;;;
;;; Registers for the bitmap coordinate math block
;;;

XY_BASE = $D301         ; Starting address of the bitmap
XY_POS_X = $D304        ; X-coordinate desired
XY_POS_Y = $D306        ; Y-coordinate desired
XY_OFFSET = $D308       ; Offset within an MMU bank of the pixel for (X, Y)
XY_BANK = $D30A         ; MMU bank containing the pixel for (X, Y)
XY_ADDRESS = $D30B      ; System address of the pixel for (X, Y)
