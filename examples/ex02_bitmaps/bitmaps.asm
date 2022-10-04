;;;
;;; Example code to show how to display a bitmap on the C256jr
;;;

;
; Definitions
;

bitmap_base = $10000        ; The base address of our bitmap

; Point the reset vector to the start of code to kick start it

* = $FFFC

reset:  .word <>start

;
; Define some variables
;

* = $0080

pointer     .word ?             ; A pointer we'll use
bm_bank     .byte ?             ; The bank number for bitmap
line        .byte ?             ; The number of the current line being drawn
column      .word ?             ; The number of the column being drawn

* = $e000

start:      sei                 ; Turn off interrupts

;
; Initialize the LUT to greyscale from (0, 0, 0) to (255, 255, 255)
;

            lda #$01            ; Set the I/O page to #1
            sta $0001

            lda #$00            ; pointer will be used to point to a particular LUT entry
            sta pointer
            lda #$D0
            sta pointer+1

            lda #0              ; Start with black

lut_loop:   ldy #0
            sta (pointer),y     ; Set the blue component
            iny
            pha
            eor #$ff
            inc a
            pha
            lda #0
            sta (pointer),y     ; Set the green component
            iny
            pla
            sta (pointer),y     ; Set the red component
            iny
            pla

            inc a               ; Go to the next color
            beq lut_done        ; If we are back to black, we're done with the LUT

            pha                 ; Move pointer to the next LUT entry (+ 4)
            clc
            lda pointer
            adc #4
            sta pointer
            lda pointer+1
            adc #0
            sta pointer+1
            pla
            bra lut_loop

lut_done:

;
; Turn on the bitmap graphics display, turn off the border
;

            stz $0001           ; Go back to I/O page #0

            lda #$0C            ; enable GRAPHICS and BITMAP. Disable TEXT
            sta $D000           ; Save that to VICKY master control register 0
            stz $D001           ; Make sure we're just in 320x240 mode (VICKY master control register 1)

            lda #$00            ; Turn off the border
            sta $D004

            lda #$10            ; Border is 16 pixels wide
            sta $D008
            sta $D009

            lda #$80
            sta $d005           ; Set border red
            sta $d006           ; Set border blue
            sta $d007           ; Set border green

            stz $D00D           ; Set background color to black
            stz $D00E
            stz $D00F

            lda #$20            ; Set up layers (we'll cover this later)
            sta $D002
            lda #$01
            sta $D003

;
; Turn on bitmap #0
;

            lda #$01            ; Use graphics LUT #0, and enable bitmap
            sta $D100

            lda #<bitmap_base   ; Set the low byte of the bitmap's address
            sta $D101
            lda #>bitmap_base   ; Set the middle byte of the bitmap's address
            sta $D102
            lda #`bitmap_base   ; Set the upper two bits of the bitmap's address
            and #$03
            sta $D103

            ; Set the line number to 0
            stz line

            ; Calculate the bank number for the bitmap
            lda #(bitmap_base >> 13)
            sta bm_bank

bank_loop:  stz pointer         ; Set the pointer to start of the current bank
            lda #$20
            sta pointer+1

            ; Set the column to 0
            stz column
            stz column+1

            ; Alter the LUT entries for $2000 -> $bfff

            lda #$80            ; Turn on editing of MMU LUT #0, and work off #0
            sta $0000

            lda bm_bank
            sta $0009           ; Set the bank we will map to $2000 - $3fff

            stz $0000           ; Turn off editing of MMU LUT #0

            ; Fill the line with the color..

loop2:      lda line            ; The line number is the color of the line
            sta (pointer)

inc_column: inc column          ; Increment the column number
            bne chk_col
            inc column+1

chk_col:    lda column          ; Check to see if we have finished the row
            cmp #<320
            bne inc_point
            lda column+1
            cmp #>320
            bne inc_point

            lda line            ; If so, increment the line number
            inc a
            sta line
            cmp #240            ; If line = 240, we're done
            beq done

            stz column          ; Set the column to 0
            stz column+1

inc_point:  inc pointer         ; Increment pointer
            bne loop2           ; If < $4000, keep looping
            inc pointer+1
            lda pointer+1
            cmp #$40
            bne loop2

            inc bm_bank         ; Move to the next bank
            bra bank_loop       ; And start filling it

done:       nop                 ; Lock up here
            bra done
