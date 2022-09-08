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

* = $0010

pointer     .word ?             ; A pointer we'll use
tmp         .byte ?             ; A scratch variable
line        .byte ?             ; The number of the bitmap line we're changing
line_sys    .long ?             ; 24-bit system address of the current line in the bitmap
line_bank   .byte ?             ; Number of the memory bank (8KB) the current line is in
line_cpu    .word ?             ; 16-bit CPU address of the current line

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

            stz line            ; Start with line #0

            lda #<bitmap_base   ; Set the base system address of the bitmap
            sta line_sys
            lda #>bitmap_base
            sta line_sys+1
            lda #`bitmap_base
            sta line_sys+2

            ; Calculate the bank of the line
            ; line_bank := (line_sys & 0xfe000) >> 13
            ; Actually calculated differently to save cycles

loop1:      lda line_sys+2      ; Get upper bits of address
            and #$0f
            sta line_bank       ; And stick them in line_bank

            lda line_sys+1      ; Get the next 3 bits of the address
            and #$e0
            sta tmp             ; Into tmp

            asl tmp             ; Shift the three bits into line_bank
            rol line_bank
            asl tmp
            rol line_bank
            asl tmp
            rol line_bank

            ; Calculate pointer address of line within CPU memory
            ; pointer := (line_sys & 0x1fff) + 0x8000;

            lda line_sys        ; Offset within bank...
            sta pointer
            lda line_sys+1
            and #$1f
            ora #$80            ; Plus $8000 for address of the CPU bank
            sta pointer+1

            ; Fill the line with the color... first 256 pixels

            lda line            ; The line will be colored using the color with its number as index

            ldy #0
loop2:      sta (pointer),y
            iny
            bne loop2

            inc pointer+1       ; Move pointer to the next page

            ; Fill the line with the color... second 64 pixels

loop3:      sta (pointer),y
            iny
            cmp #64             ; Have we reached the end of the line?
            bne loop3           ; No, keep looping

            inc a               ; Move to the next line
            cmp #240            ; Have we reached the last line?
            beq done            ; Yes: we're done

            sta line            ; Save the new line number

            clc                 ; Move the line system address forward by 320 bytes
            lda line_sys
            adc #<320
            sta line_sys
            lda line_sys+1
            adc #>320
            sta line_sys+1

            bra loop1           ; And process this new line

done:       nop                 ; Lock up here
            bra done
