;;;
;;; An example showing how tiles work
;;;

.include "../common/f256jr.asm"         ; Include register definitions for the F256jr
.include "../common/f256_tiles.asm"     ; Include the registers for the tiles

;
; Definitions
;

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
            ; Set up TinyVicky to display tiles
            ;
            lda #$14                    ; Graphics and Tile engines enabled
            sta VKY_MSTR_CTRL_0
            stz VKY_MSTR_CTRL_1         ; 320x240 @ 60Hz

            stz VKY_BRDR_CTRL           ; No border
cfb53b

            lda #$19                    ; Background: midnight blue
            sta VKY_BKG_COL_R
            lda #$19
            sta VKY_BKG_COL_G
            lda #$70
            sta VKY_BKG_COL_B

            ;
            ; Load the tile set LUT into memory
            ;

            lda #$01                    ; Switch to I/O Page #1
            sta MMU_IO_CTRL

            lda #<tiles_clut_start      ; Set the source pointer to the palette data
            sta ptr_src
            lda #>tiles_clut_start
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
            cmp #20
            beq done_lut                ; Until we have copied all 20

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
            ; Set tile set #0 to our image
            ;

            lda #<tiles_img_start
            sta VKY_TS0_ADDR_L
            lda #>tiles_img_start
            sta VKY_TS0_ADDR_M
            lda #`tiles_img_start
            sta VKY_TS0_ADDR_H

            ;
            ; Set tile map #0
            ;

            lda #$01                    ; 16x16 tiles, enable
            sta VKY_TM0_CTRL

            lda #22                     ; Our tile map is 20x15
            sta VKY_TM0_SIZE_X
            lda #16
            sta VKY_TM0_SIZE_Y

            lda #<tile_map              ; Point to the tile map
            sta VKY_TM0_ADDR_L
            lda #>tile_map
            sta VKY_TM0_ADDR_M
            lda #`tile_map
            sta VKY_TM0_ADDR_H

            lda #$0F                    ; Set scrolling to (15, 0)
            sta VKY_TM0_POS_X_L
            stz VKY_TM0_POS_X_H
            stz VKY_TM0_POS_Y_L
            stz VKY_TM0_POS_Y_H

lock:       nop
            bra lock

;
; The tile map to display... all tiles are from tile set #0 and use CLUT #0
;

tile_map:   .word $0004, $0001, $0000, $0001, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0004, $0000, $0004, $0000
            .word $0000, $0000, $0001, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0004, $0000, $0000
            .word $0000, $0001, $0000, $0001, $0000, $0000, $0006, $0007, $0007, $0007, $0007, $0007, $0007, $0007, $0007, $0008, $0000, $0000, $0004, $0000, $0004, $0000
            .word $0000, $0000, $0000, $0000, $0000, $0000, $0009, $0001, $0002, $0003, $0004, $0005, $0000, $0000, $0000, $000A, $0000, $0000, $0000, $0000, $0000, $0000
            .word $0000, $0000, $0000, $0000, $0000, $0000, $0009, $0002, $0001, $0002, $0003, $0004, $0005, $0000, $0000, $000A, $0000, $0000, $0000, $0000, $0000, $0000
            .word $0000, $0000, $0000, $0000, $0000, $0000, $0009, $0003, $0002, $0001, $0002, $0003, $0004, $0005, $0000, $000A, $0000, $0000, $0000, $0000, $0000, $0000
            .word $0000, $0000, $0000, $0000, $0000, $0000, $0009, $0004, $0003, $0002, $0001, $0002, $0003, $0004, $0005, $000A, $0000, $0000, $0000, $0000, $0000, $0000
            .word $0000, $0000, $0000, $0000, $0000, $0000, $0009, $0005, $0004, $0003, $0002, $0001, $0002, $0003, $0004, $000A, $0000, $0000, $0000, $0000, $0000, $0000
            .word $0000, $0000, $0000, $0000, $0000, $0000, $0009, $0000, $0005, $0004, $0003, $0002, $0001, $0002, $0003, $000A, $0000, $0000, $0000, $0000, $0000, $0000
            .word $0000, $0000, $0000, $0000, $0000, $0000, $0009, $0000, $0000, $0005, $0004, $0003, $0002, $0001, $0002, $000A, $0000, $0000, $0000, $0000, $0000, $0000
            .word $0000, $0000, $0000, $0000, $0000, $0000, $0009, $0000, $0000, $0000, $0005, $0004, $0003, $0002, $0001, $000A, $0000, $0000, $0000, $0000, $0000, $0000
            .word $0000, $0000, $0000, $0000, $0000, $0000, $000B, $000C, $000C, $000C, $000C, $000C, $000C, $000C, $000C, $000D, $0000, $0000, $0000, $0000, $0000, $0000
            .word $0000, $0003, $0000, $0003, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0002, $0000, $0002, $0000
            .word $0000, $0000, $0003, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0002, $0000, $0000
            .word $0000, $0003, $0000, $0003, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0002, $0000, $0002, $0000
            .word $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0002, $0000, $0000, $0004

.include "tiles_pal.asm"
.include "tiles_pix.asm"
