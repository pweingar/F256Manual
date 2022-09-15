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

* = $0020

pointer     .word ?             ; A pointer we'll use
tmp         .byte ?             ; A scratch variable
line        .byte ?             ; The number of the bitmap line we're changing
line_sys    .long ?             ; 24-bit system address of the current line in the bitmap
line_bank   .byte ?             ; Number of the memory bank (8KB) the current line is in
line_cpu    .word ?             ; 16-bit CPU address of the current line

* = $e000

start:

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
            sta $D001           ; Make sure we're just in 320x240 mode (VICKY master control register 1)

            stz $D004           ; Turn off the border

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

            lda #0
            sta pointer
            lda #$20
            sta pointer+1

            ; Alter the LUT entries for $2000 -> $bfff

            lda #$80            ; Turn on editing of MMU LUT #0, and work off #0
            sta $0000

            lda #$08            ; $2000 - $3fff -> $1:0000 - $1:1fff
            sta $0009

            stz $0000           ; Turn off editing of MMU LUT #0, and work off #0

            lda #$ff
            ldy #0
loop4:      sta $2000,y         ; Write to several pages, just to make it more visible
            sta $2100,y
            sta $2200,y
            sta $2300,y
            iny
            bne loop4

loop5:      nop
            bra loop5

            ; Fill the line with the color... first 256 pixels

loop3:      sec
            lda pointer+1
            sbc #$20
            inc a
            ldy #0
loop2:      sta (pointer),y
            iny
            bne loop2

            lda pointer+1
            inc a
            sta pointer+1
            cmp #$c0
            bne loop3

lock        nop
            bra lock


done:       nop                 ; Lock up here
            bra done
