;;;
;;; An example showing how sprites work
;;;

.include "../common/f256jr.asm"         ; Include register definitions for the F256jr
.include "../common/f256_sprites.asm"   ; Include the registers for the sprites

;
; Definitions
;

bps = 16*16                             ; The number of bytes in a sprite

; Point the reset vector to the start of code to kick start it

* = $FFFC

reset:  .word <>start

;
; Define some variables
;

* = $0080

ptr_src     .word ?                     ; A pointer to data to read
ptr_dst     .word ?                     ; A pointer to data to write

* = $e000

start:      sei                         ; Turn off interrupts

            ;
            ; Set up TinyVicky to display sprites
            ;
            lda #$24                    ; Graphics and Sprite engines enabled
            sta VKY_MSTR_CTRL_0
            stz VKY_MSTR_CTRL_1         ; 320x240 @ 60Hz

            stz VKY_BRDR_CTRL           ; No border

            lda #$96                    ; Background: lavender
            sta VKY_BKG_COL_R
            lda #$7B
            sta VKY_BKG_COL_G
            lda #$B6
            sta VKY_BKG_COL_B

            ;
            ; Load the sprite LUT into memory
            ;

            lda #$01                    ; Switch to I/O Page #1
            sta MMU_IO_CTRL

            lda #<balls_clut_start      ; Set the source pointer to the palette data
            sta ptr_src
            lda #>balls_clut_start
            sta ptr_src+1

            lda #<VKY_GR_CLUT_0         ; Set the destination pointer to Graphics CLUT 1
            sta ptr_dst
            lda #>VKY_GR_CLUT_0
            sta ptr_dst+1

            ldx #0                      ; X is a counter for the number of colors copied
color_loop: ldy #0                      ; Y is a pointer to the component within a CLUT color
comp_loop:  lda (ptr_src),y             ; Read a byte from the code
            sta (ptr_dst),y             ; And write it to the CLUT
            iny                         ; Move to the next byte
            cpy #4
            bne comp_loop               ; Continue until we have copied 4 bytes

            inx                         ; Move to the next color
            cmp #16
            beq done_lut                ; Until we have copied all 16

            clc                         ; Advance ptr_src to the next source color entry
            lda ptr_src
            adc #4
            sta ptr_src
            lda ptr_src+1
            adc #0
            sta ptr_src+1

            clc                         ; Advance ptr_dst to the next destination color entry
            lda ptr_dst
            adc #4
            sta ptr_dst
            lda ptr_dst+1
            adc #0
            sta ptr_dst+1

            bra color_loop              ; And start copying that new color

done_lut:   stz MMU_IO_CTRL             ; Go back to I/O Page 0

            ;
            ; Set up sprite #0
            ;
init_sp0:   lda #<balls_img_start       ; Address = balls_img_start
            sta VKY_SP0_AD_L
            lda #>balls_img_start
            sta VKY_SP0_AD_M
            stz VKY_SP0_AD_H

            lda #32
            sta VKY_SP0_POS_X_L         ; (x, y) = (32, 32)... should be upper-left corner of the screen
            stz VKY_SP0_POS_X_H

            lda #32
            sta VKY_SP0_POS_Y_L
            stz VKY_SP0_POS_Y_H

            lda #$41                    ; Size = 16x16, Layer = 0, LUT = 0, Enabled
            sta VKY_SP0_CTRL

lock:       nop
            bra lock

.include "balls_pal.asm"
.include "balls_pix.asm"
