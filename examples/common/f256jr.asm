;;;
;;; I/O register address definitions
;;;

;;
;; MMU Registers
;;

MMU_MEM_CTRL = $0001            ; MMU Memory Control Register
MMU_IO_CTRL = $0002             ; MMU I/O Control Register
MMU_MEM_BANK_0 = $0008          ; MMU Edit Register for bank 0 ($0000 - $1FFF)
MMU_MEM_BANK_1 = $0009          ; MMU Edit Register for bank 1 ($2000 - $3FFF)
MMU_MEM_BANK_2 = $000A          ; MMU Edit Register for bank 2 ($4000 - $5FFF)
MMU_MEM_BANK_3 = $000B          ; MMU Edit Register for bank 3 ($6000 - $7FFF)
MMU_MEM_BANK_4 = $000C          ; MMU Edit Register for bank 4 ($8000 - $9FFF)
MMU_MEM_BANK_5 = $000D          ; MMU Edit Register for bank 5 ($A000 - $BFFF)
MMU_MEM_BANK_6 = $000E          ; MMU Edit Register for bank 6 ($C000 - $DFFF)
MMU_MEM_BANK_7 = $000F          ; MMU Edit Register for bank 7 ($E000 - $FFFF)

;;
;; Vicky Registers
;;

VKY_MSTR_CTRL_0 = $D000         ; Vicky Master Control Register 0
VKY_MSTR_CTRL_1 = $D001         ; Vicky Master Control Register 1

VKY_LAYER_CTRL_0 = $D002        ; Vicky Layer Control Register 0
VKY_LAYER_CTRL_1 = $D002        ; Vicky Layer Control Register 1

VKY_BRDR_CTRL = $D004           ; Vicky Border Control Register

VKY_BKG_COL_B = $D00D           ; Vicky Graphics Background Color Blue Component
VKY_BKG_COL_G = $D00E           ; Vicky Graphics Background Color Green Component
VKY_BKG_COL_R = $D00F           ; Vicky Graphics Background Color Red Component

;;
;; Bitmap Registers
;;

VKY_BM0_CTRL = $D100            ; Bitmap #0 Control Register
VKY_BM0_ADDR_L = $D101          ; Bitmap #0 Address bits 7..0
VKY_BM0_ADDR_M = $D102          ; Bitmap #0 Address bits 15..8
VKY_BM0_ADDR_H = $D103          ; Bitmap #0 Address bits 17..16

VKY_BM1_CTRL = $D108            ; Bitmap #1 Control Register
VKY_BM1_ADDR_L = $D109          ; Bitmap #1 Address bits 7..0
VKY_BM1_ADDR_M = $D10A          ; Bitmap #1 Address bits 15..8
VKY_BM1_ADDR_H = $D10B          ; Bitmap #1 Address bits 17..16

;;
;; Color Lookup Tables
;;

VKY_GR_CLUT_0 = $D000           ; Graphics LUT #0
VKY_GR_CLUT_1 = $D400           ; Graphics LUT #1
VKY_GR_CLUT_2 = $D800           ; Graphics LUT #2
VKY_GR_CLUT_3 = $DC00           ; Graphics LUT #3
