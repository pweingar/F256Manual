;;;
;;; Example of using the real time clock
;;;


.include "../common/f256jr.asm"         ; Include register definitions for the F256jr
.include "../common/f256_irq.asm"       ; Include register definitions for the interrupt controller
.include "../common/f256_rtc.asm"       ; Include the registers for the real time clock

;
; Definitions
;

ok_cint = $FF81
ok_cout = $FFD2

; Point the reset vector to the start of code to kick start it

* = $FFFC

reset:  .word <>start

* = $e000

start:      jsr ok_cint                 ; Initialize the text screen

            stz MMU_IO_CTRL             ; Make sure we're on I/O page 0

            lda RTC_CTRL                ; Stop the update of the RTC registers
            ora #RTC_UTI | RTC_STOP | RTC_24HR
            sta RTC_CTRL

            stz MMU_IO_CTRL
            lda RTC_HOURS               ; Print the hours
            jsr putbcd

            lda #':'
            jsr ok_cout

            stz MMU_IO_CTRL
            lda RTC_MINS                ; Print the minutes
            jsr putbcd

            lda #':'
            jsr ok_cout

            stz MMU_IO_CTRL
            lda RTC_SECS                ; Print the seconds
            jsr putbcd

            stz MMU_IO_CTRL
            lda RTC_CTRL                ; Reenable the update of the registers
            and #~RTC_UTI
            sta RTC_CTRL

lock:       nop
            bra lock

;
; Print a BCD number to the screen
;
putbcd:     pha                         ; Save the number
            and #$F0                    ; Isolate the upper digit
            lsr a
            lsr a
            lsr a
            lsr a

            clc                         ; Convert to ASCII
            adc #'0'
            jsr ok_cout                 ; And print

            pla                         ; Get the full number back
            and #$0F                    ; Isolate the lower digit

            clc                         ; Convert to ASCII
            adc #'0'
            jsr ok_cout                 ; And print

            rts
