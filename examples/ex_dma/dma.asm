;;;
;;; Example code to show how to use the DMA features with bitmaps
;;;

.include "../common/f256jr.asm"     ; Include register definitions for the F256jr
.include "../common/f256_dma.asm"   ; Include the DMA registers

;
; Definitions
;

bitmap_base = $10000        ; The base address of our bitmap
bitmap_size = 640*480

; Point the reset vector to the start of code to kick start it

* = $FFFC

reset:  .word <>start

;
; Define some variables
;

* = $0080

pointer     .word ?             ; A pointer we'll use


* = $e000

start:      sei                 ; Turn off interrupts

;
; Initialize the LUT to greyscale from (255, 0, 0) to (0, 0, 255)
;

            lda #$01            ; Set the I/O page to #1
            sta MMU_IO_CTRL

            lda #<VKY_GR_CLUT_0 ; pointer will be used to point to a particular LUT entry
            sta pointer
            lda #>VKY_GR_CLUT_0
            sta pointer+1

            ldx #0              ; Start with blue = 0

lut_loop:   ldy #0              ; And start at the offset for blue
            txa                 ; Take the current blue color level
            sta (pointer),y     ; Set the blue component
            iny

            lda #0
            sta (pointer),y     ; Set the green component to 0
            iny

            txa                 ; Get the blue component again
            eor #$ff            ; And compute the 2's complement of it
            inc a
            sta (pointer),y     ; Set the red component
            iny

            inx                 ; Go to the next color
            beq lut_done        ; If we are back to black, we're done with the LUT

            clc                 ; Move pointer to the next LUT entry (+ 4)
            lda pointer
            adc #4
            sta pointer
            lda pointer+1
            adc #0
            sta pointer+1

            bra lut_loop

lut_done:

;
; Turn on the bitmap graphics display, turn off the border
;

            stz MMU_IO_CTRL     ; Go back to I/O page #0

            lda #$0C            ; enable GRAPHICS and BITMAP. Disable TEXT
            sta VKY_MSTR_CTRL_0 ; Save that to VICKY master control register 0
            stz VKY_MSTR_CTRL_1 ; Make sure we're just in 320x240 mode (VICKY master control register 1)

            lda #$00            ; Turn off the border
            sta VKY_BRDR_CTRL

            stz VKY_BKG_COL_R   ; Set background color to black
            stz VKY_BKG_COL_G
            stz VKY_BKG_COL_B

            lda #$20            ; Layer 0 = BM 0, Layer 1 = TM 0
            sta VKY_LAYER_CTRL_0
            lda #$01            ; Layer 2 = BM 1
            sta VKY_LAYER_CTRL_1

;
; Turn on bitmap #0
;

            stz VKY_BM1_CTRL    ; Make sure bitmap 1 is turned off

            lda #$01            ; Use graphics LUT #0, and enable bitmap
            sta VKY_BM0_CTRL

            lda #<bitmap_base   ; Set the low byte of the bitmap's address
            sta VKY_BM0_ADDR_L
            lda #>bitmap_base   ; Set the middle byte of the bitmap's address
            sta VKY_BM0_ADDR_M
            lda #`bitmap_base   ; Set the upper two bits of the bitmap's address
            and #$03
            sta VKY_BM0_ADDR_H

            ; Fill the bitmap with 0

            lda #$ff
            sta DMA_CTRL_FILL   ; We will fill the screen with 0

            lda #<bitmap_base   ; Our bitmap will be the destination
            sta DMA_DST_ADDR
            lda #>bitmap_base
            sta DMA_DST_ADDR+1
            lda #`bitmap_base
            and #$03
            sta DMA_DST_ADDR+2

            lda #<bitmap_size   ; We will write 640*480 bytes
            sta DMA_COUNT
            lda #>bitmap_size
            sta DMA_COUNT+1

            lda #DMA_CTRL_FILL | DMA_CTRL_ENABLE | DMA_CTRL_START
            sta DMA_CTRL

wait_dma:   lda DMA_STATUS      ; Wait until DMA is not busy
            bit #DMA_STAT_BUSY
            bne wait_dma

done:       nop                 ; Lock up here
            bra done
