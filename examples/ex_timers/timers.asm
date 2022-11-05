;;;
;;; Example of a free running timer
;;;


.include "../common/f256jr.asm"         ; Include register definitions for the F256jr
.include "../common/f256_irq.asm"       ; Include register definitions for the interrupt controller
.include "../common/f256_timers.asm"    ; Include the registers for the interval timers

;
; Definitions
;

ok_cint = $FF81
ok_cout = $FFD2

; Variables

* = $0080

counter:    .byte ?
trigger:    .byte ?                     ; A flag register
time_tmp:   .dword ?                    ; A temporary copy of the timer value

; Point the reset vector to the start of code to kick start it

* = $FFFC

reset:  .word <>start
irq:    .word ?

* = $e000

start:      sei                         ; Turn off interrupts

            jsr ok_cint                 ; Initialize the screen

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

            ; Enable counting, counting up, clearing on reaching the target, and triggering interrupts
            lda #TM_CTRL_ENABLE | TM_CTRL_UP_DOWN | TM_CTRL_INTEN
            sta TM1_CTRL

            lda TM1_VALUE_L             ; Initialize our copy of the timer
            sta time_tmp
            lda TM1_VALUE_M
            sta time_tmp+1
            lda TM1_VALUE_H
            sta time_tmp+2

            stz counter                 ; Set the counter for the spinner to 0
            stz trigger                 ; Make sure the trigger is off

            cli                         ; Enable interrupts

loop:       sei                         ; Ignore interrupts for the moment

            lda #$93                    ; CBM CLS code
            jsr ok_cout

            ldx counter                 ; Print a little spinner character for each interrupt
            inx
            cpx #4
            bne save_count
            ldx #0
save_count: stx counter
            lda spinner,x
            jsr ok_cout

            lda #' '                    ; Print a space
            jsr ok_cout

            lda time_tmp+2              ; Print our copy of the timer
            jsr prhex
            lda time_tmp+1
            jsr prhex
            lda time_tmp
            jsr prhex

            cli                         ; Restore interrupts

wait:       wai                         ; Wait for an interrupt

            lda #$01                    ; Wait for trigger bit 0 to be set
            trb trigger
            beq wait                    ; If not set, keep waiting

            bra loop                    ; Otherwise, print out the new timer value

;
; Interrupt handler for the timer
;
my_int:     .proc
            pha                         ; Save the value of the interrupted code's accumulator

            lda MMU_IO_CTRL             ; Save the interrupted I/O page
            pha

            stz MMU_IO_CTRL             ; Go back to I/O page 0

            lda INT_PEND_0              ; Only process interrupt if it's from TIMER1
            and #INT05_TIMER_1
            cmp #INT05_TIMER_1
            bne skip_irq

            lda TM1_VALUE_L             ; Just copy the time over
            sta time_tmp
            lda TM1_VALUE_M
            sta time_tmp+1
            lda TM1_VALUE_H
            sta time_tmp+2

            lda #$01                    ; Trigger the printing of the result
            sta trigger

skip_irq:   lda #$FF
            sta INT_PEND_0              ; Clear the interrupt

            pla                         ; Restore the original I/O page
            sta MMU_IO_CTRL

            pla                         ; Restore the value of the interrupted code's accumulator
            rti
            .pend

;
; Print the HEX byte in A
;
prhex:      .proc
            pha
            lsr a
            lsr a
            lsr a
            lsr a
            and #$0F
            tax
            lda hexdigits,x
            jsr ok_cout

            pla
            and #$0F
            tax
            lda hexdigits,x
            jsr ok_cout

            rts
            .pend

hexdigits:  .text "0123456789ABCDEF"
spinner:    .byte $2D, $5C, $7C, $2F
