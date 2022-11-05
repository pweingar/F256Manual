;;;
;;; Code to support the text screen
;;;

.section zp

conline     .word ?                         ; Pointer to the current line in text/color matrix
pointer     .word ?                         ; General purpose pointer
row         .byte ?                         ; Current row number
column      .byte ?                         ; Current column number
curcolor    .byte ?                         ; The current color for text

.section code

;
; Set the cursor position to (column, row)
;
concurs:    .proc
            stz MMU_IO_CTRL                 ; Go to I/O page 0

            lda column                      ; Set the column
            sta VKY_CRSR_X_L
            stz VKY_CRSR_X_H

            lda row                         ; Set the row
            sta VKY_CRSR_Y_L
            stz VKY_CRSR_Y_H

            rts
            .pend

;
; Set the position of the kernel variables and console cursor to (x, y)
;
consetxy:   .proc
            cpx #80
            blt set_x
            ldx #79
set_x:      stx column

            cpy #30
            blt set_y
            ldy #29
set_x:      sty row

            stz conline
            lda #$c0
            sta conline+1

loop:       cpx #0
            beq set_hw_xy

            clc
            lda conline
            adc #80
            sta conline
            lda conline+1
            adc #0
            sta conline+1

            dex
            bra loop

done:       jsr concurs

            rts
            .pend

;
; Erase the current line
;
conel:      .proc
            lda #$02                        ; Switch to the text page
            sta MMU_IO_CTRL

            lda #' '
            ldy #0
loop1:      sta (conline),y
            iny
            cpy #80
            bne loop1

            lda #$03                        ; Switch to the color page
            sta MMU_IO_CTRL

            lda curcolor
            ldy #0
loop2:      sta (conline),y
            iny
            cpy #80
            bne loop2

            rts
            .pend

;
; Clear the console screen
;
concls:     .proc
            ldx #0
            ldy #0
loop:       jsr consetxy                    ; Move to the line
            jsr conel                       ; And clear it

            ldx  #0                         ; Compute the next (x, y)
            inc row
            ldy row
            cpy #30                         ; If y < 30...
            bne loop                        ; ... repeat for this new line

            ldx #0                          ; Otherwise, set the cursor to the home position
            ldy #0
            jsr consetxy

            rts
            .pend

;
; Init Text CLUTs
;
coninitlut: .proc
            stz MMU_IO_CTRL                 ; Go to I/O page 0

            ldx #0
loop:       lda conlut,x                    ; For each byte in the CLUT
            sta VKY_TXT_FGLUT,x             ; Copy it to the text foreground CLUT
            sta VKY_TXT_BGLUT,x             ; ... and then the text background CLUT
            inx                             ; Go to the next byte
            cpx #16*4
            bne loop                        ; And keep copying until we've done all 16 colors

            rts
            .pend

;
; Initialize the text mode font
;
coninitfon: .proc
            lda #$01
            stz MMU_IO_CTRL                 ; Go to I/O page 1

            stz pointer                     ; Point to the beginning of the font storage
            lda #$c0
            sta pointer+1

            ldy #0
loop2:      lda confont,y                   ; Get a byte of the font data
            sta (pointer),y                 ; Save it to the Vicky font area
            iny                             ; Move to the next byte
            bne loop2                       ; Until we've copied 256 bytes

            lda pointer+1                   ; Move to the next page of font data
            inc a
            sta pointer+1
            cmp #$c8                        ; Until we've copied the whole font
            bne loop2

            rts
            .pend

;
; Initialize the text screen
;
coninit:    stz MMU_IO_CTRL                 ; Switch to I/O page 0

            lda #1                          ; Set to text mode, 320x240
            sta VKY_MSTR_CTRL_0
            stz VKY_MSTR_CTRL_1

            stz VKY_BRDR_CTRL               ; Turn off the border

            lda #$01                        ; Turn on cursor with no flashing
            sta VKY_CRSR_CTRL

            lda #$ff                        ; Set the cursor character
            sta VKY_CRSR_CHAR

            lda #$74                        ; Light grey on blue for the default text color
            sta curcolor

            jsr coninitlut                  ; Initialize the text CLUTs
            jsr coninitfon                  ; Initialize the text font
            jsr concls                      ; Clear the screen

            rts

;
; Return the console status in A
;
iconst:     rts

;
; Return the next keypress in A
;
iconin:     rts

;
; Print the character in A to the text screen
;
iconout:    rts

;
; Color lookup table for the console (GBRA)
;
conlut:     .byte 000, 000, 000, 000        ; Black
            .byte 000, 000, 128, 000        ; Red
            .byte 128, 000, 000, 000        ; Green
            .byte 128, 000, 128, 000        ; Yellow
            .byte 000, 128, 000, 000        ; Blue
            .byte 000, 128, 128, 000        ; Purple
            .byte 128, 128, 000, 000        ; Cyan
            .byte 192, 192, 192, 000        ; Grey
            .byte 128, 128, 128, 000        ; Bright Black
            .byte 000, 000, 255, 000        ; Bright Red
            .byte 255, 000, 000, 000        ; Bright Green
            .byte 255, 000, 255, 000        ; Bright Yellow
            .byte 000, 255, 000, 000        ; Bright Blue
            .byte 000, 255, 255, 000        ; Magenta
            .byte 255, 255, 000, 000        ; Bright Cyan
            .byte 255, 255, 255, 000        ; White

.align $100
confont:    .binary "bios02/foenix_8x8.bin"
