;;;
;;; Example of a free running timer
;;;


.include "../common/f256jr.asm"         ; Include register definitions for the F256jr
.include "../common/f256_timers.asm"    ; Include the registers for the interval timers

;
; Definitions
;

; Point the reset vector to the start of code to kick start it

* = $FFFC

reset:  .word <>start

* = $e000

start:      sei                         ; Turn off interrupts

            stz MMU_IO_CTRL             ; Switch to I/O Page 0

            lda #$01                    ; Text Mode
            sta VKY_MSTR_CTRL_0
            stz VKY_MSTR_CTRL_1         ; 80x60 @ 60Hz

            lda #$02                    ; Go to Text page
            sta MMU_IO_CTRL

            lda #'a'                    ; Save an initial test character
            sta $C000

            lda #$03                    ; Go to color page
            sta MMU_IO_CTRL

            lda #$F0                    ; Set the color
            sta $C000

            stz MMU_IO_CTRL             ; Switch to I/O Page 0

            lda #TM_CTRL_CLEAR
            sta TM1_CTRL

            lda #TM_CTRL_ENABLE | TM_CTRL_UP_DOWN | TM_CTRL_RECLEAR
            sta TM1_CTRL

loop:       lda TM1_VALUE_L             ; Get the low byte of the time
            and #$0f                    ; is it divisible by 15?
            bne loop                    ; no: keep waiting

            lda #$02                    ; Go to Text page
            sta MMU_IO_CTRL

            inc $C000                   ; Increment the character

            stz MMU_IO_CTRL
            bra loop
