;;;
;;; Example of polling joystick 1
;;;

.include "../common/f256jr.asm"         ; Include register definitions for the F256jr
.include "../common/f256_via.asm"       ; Include register definitions for the F256jr VIA

;
; Definitions
;

ok_cint = $FF81
ok_cout = $FFD2

; Variables

* = $0080

value:      .byte ?                     ; Variable to store the previous value of the joystick
prv:        .byte ?                     ; Copy of value for printing

; Point the reset vector to the start of code to kick start it

* = $FFFC

reset:  .word <>start
irq:    .word ?

* = $e000

start:      jsr ok_cint                 ; Set up the screen

            lda #$FF                    ; Set the previous value to $FF
            sta value

            stz MMU_IO_CTRL             ; Switch to I/O Page 0

            lda #$00                    ; Set VIA Port A to input
            sta VIA_DDRA

loop1:      lda #147                    ; Print the CBM clear screen code
            jsr ok_cout

            lda value                   ; Copy the value to prv
            sta prv

            ldx #8                      ; Loop for all eight bits
loop2:      asl prv                     ; Shift MSB into the carry
            bcc is0                     ; If it's 0, print '0'

            lda #'1'                    ; Otherwise, print '1'
            jsr ok_cout
            bra repeat                  ; And go to the next bit

is0:        lda #'0'                    ; Print '0'
            jsr ok_cout

repeat:     dex                         ; Count down
            bne loop2                   ; Repeat until we've done all 8 bits

            stz MMU_IO_CTRL             ; Switch to I/O Page 0

wait:       lda VIA_IORA                ; Get the status of port A
            cmp value                   ; Is it different from before?
            beq wait                    ; Yes: keep waiting

            sta value                   ; Save this value as the previous one
            bra loop1                   ; And go to print it
