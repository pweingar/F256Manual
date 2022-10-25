;;;
;;; Example of a free running timer
;;;


.include "../common/f256jr.asm"         ; Include register definitions for the F256jr
.include "../common/f256_irq.asm"       ; Include register definitions for the interrupt controller
.include "../common/f256_timers.asm"    ; Include the registers for the interval timers

;
; Definitions
;

; Point the reset vector to the start of code to kick start it

* = $FFFC

reset:  .word <>start
irq:    .word ?

* = $e000

start:      sei                         ; Turn off interrupts

            stz MMU_IO_CTRL             ; Switch to I/O Page 0

            lda #$01                    ; Text Mode
            sta VKY_MSTR_CTRL_0
            stz VKY_MSTR_CTRL_1         ; 80x60 @ 60Hz

            lda #MMU_IO_TEXT            ; Go to Text page
            sta MMU_IO_CTRL

            lda #'0'                    ; Save an initial test character
            sta $C000
            lda #' '
            sta $C001
            sta $C002
            sta $C003
            sta $C004
            sta $C005

            lda #MMU_IO_COLOR           ; Go to color page
            sta MMU_IO_CTRL

            lda #$F0                    ; Set the color
            sta $C000

            stz MMU_IO_CTRL             ; Switch to I/O Page 0

            lda #<my_int                ; Set my_int as the interrupt handler
            sta irq
            lda #>my_int
            sta irq+1

            lda #~INT05_TIMER_1         ; Enable only the Timer 1 interrupt
            sta INT_MASK_0

            lda #$FF
            sta INT_MASK_1              ; Disable all group 1 interrupts

            sta INT_PEND_0              ; Clear all pending interrupts
            sta INT_PEND_1

            lda #TM_CTRL_CLEAR          ; Clear timer 1
            sta TM1_CTRL
            stz TM1_CTRL

            lda #TM_CMP_CTRL_CLR        ; Set the counter to reclear on reaching the target
            sta TM1_CMP_CTRL

            lda #120                    ; Set comparison value to 120 (~2 seconds beat)
            sta TM1_CMP_L
            stz TM1_CMP_M
            stz TM1_CMP_H

            lda #TM_CTRL_ENABLE | TM_CTRL_CLEAR | TM_CTRL_INTEN
            sta TM1_CTRL

            cli                         ; Enable interrupts

wait:       wai                         ; Wait for an interrupt
            bra wait                    ; And keep waiting

my_int:     pha

            lda MMU_IO_CTRL             ; Save the interrupted I/O page
            pha

            stz MMU_IO_CTRL             ; Go back to I/O page 0

            lda #TM_CMP_CTRL_CLR        ; Set the counter to reclear on reaching the target
            sta TM1_CMP_CTRL

            lda #TM_CTRL_ENABLE | TM_CTRL_RECLEAR | TM_CTRL_INTEN
            sta TM1_CTRL

            lda #$FF
            sta INT_PEND_0              ; Clear the interrupt

            lda #MMU_IO_TEXT            ; Go to Text page
            sta MMU_IO_CTRL

            lda $C000                   ; Is the character 9?
            cmp #'9'
            bne inc_digit

            lda #'0'                    ; Yes: reset it to zero
            bra save_digit

inc_digit:  inc a                       ; No: Increment the digit
save_digit: sta $C000                   ; And save it to the screen

skip_irq:   pla                         ; Restor the original I/O page
            sta MMU_IO_CTRL
            pla
            rti
