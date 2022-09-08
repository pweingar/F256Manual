;;;
;;; Example code to show how to display a bitmap on the C256jr
;;;

; Point the reset vector to the start of code to kick start it

* = $FFFC

reset:  .word <>start

;
; Define some variables
;

pointer     equ $0010           ; A pointer we'll use
bitmap_base equ $10000          ; The base address of our bitmap

* = $1000

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
            sta (pointer),y     ; Set the green component
            iny
            sta (pointer),y     ; Set the red component

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
