;;;
;;; An example showing how to manage the interrupt controller on the C256jr
;;;

VIRQ = $FFFE

SYS_CTRL_0 = $0000
SYS_CTRL_1 = $0001
SYS_CTRL_DSBL_IO = $40
SYS_CTRL_TEXT_PG = $02
SYS_CTRL_COLOR_PG = $03

TM1_CTRL = $D650
TM_CTRL_ENABLE = $01
TM_CTRL_CLR = $02
TM_CTRL_LOAD = $04
TM_CTRL_UPDWN = $08
TM_CTRL_RECLR = $10
TM_CTRL_RELOAD = $20
TM_CTRL_IRQEN = $80

TM1_VAL = $D658
TM1_CMP_CTR = $D65C
TM1_CMP = $D65D

;
; Interrupt Controller Registers
;
INT_PEND_0 = $D660  ; Pending register for interrupts 0 - 7
INT_PEND_1 = $D661  ; Pending register for interrupts 8 - 15
INT_MASK_0 = $D666  ; Mask register for interrupts 0 - 7
INT_MASK_1 = $D667  ; Mask register for interrupts 8 - 15

;
; Interrupt bits
;
INT00_VKY_SOF = $01
INT01_VKY_SOL = $02
INT02_PS2_KBD = $04
INT03_PS2_MOUSE = $08
INT04_TIMER_0 = $10
INT05_TIMER_1 = $20
INT06_DMA = $40
INT07_RESERVED = $80

INT10_UART = $01
INT11_VKY_2 = $02
INT12_VKY_3 = $04
INT13_VKY_4 = $08
INT14_RTC = $10
INT15_VIA = $20
INT16_IEC = $40
INT17_SDC_INSERT = $80

;
; RESET vector to kickstart the code
;
* = $FFFC

RESET       .word <>start

;
; Code
;
* = $e000

start:      ; Disable IRQ handling
            sei

            ; Load my IRQ handler into the IRQ vector
            ; NOTE: this code just takes over IRQs completely. It could save
            ;       the pointer to the old handler and chain to it when it had
            ;       handled its interrupt. But what is proper really depends on
            ;       what the program is trying to do.
            lda #<my_handler
            sta VIRQ
            lda #>my_handler
            sta VIRQ+1

            ; Mask off all but the timer 1 interrupt
            lda #$ff
            sta INT_MASK_1
            and #~INT05_TIMER_1
            sta INT_MASK_0

            ; Clear all pending interrupts
            lda #$ff
            sta INT_PEND_0
            sta INT_PEND_1

            ; Put a character in the upper right of the screen
            lda #SYS_CTRL_TEXT_PG
            sta SYS_CTRL_1

            lda #'@'
            sta $c000

            ; Set the color of the character
            lda #SYS_CTRL_COLOR_PG
            sta SYS_CTRL_1

            lda #$F0
            sta $c000
            sta $c001

            ; Go back to I/O page 0
            stz SYS_CTRL_1

            ; Make sure we're in text mode
            lda #$01            ; enable TEXT
            sta $D000           ; Save that to VICKY master control register 0
            stz $D001

            ; Clear the timer
            lda #TM_CTRL_CLR
            STA TM1_CTRL

            ; Clear the load value (just to be on the safe side)
            stz TM1_VAL
            stz TM1_VAL+1
            stz TM1_VAL+2

            ; Set the target to 60
            lda #60
            sta TM1_CMP
            stz TM1_CMP+1
            stz TM1_CMP+2

            lda #0
            sta TM1_CMP_CTR

            ; Start the counter going up, clearing on reaching the target, and enabling IRQ
            lda #TM_CTRL_ENABLE | TM_CTRL_UPDWN
            sta TM1_CTRL

            ; Re-enable IRQ handling
            ; cli

loop:       ; Just loop forever... a real program will do stuff here
            ldx TM1_VAL

            lda #SYS_CTRL_TEXT_PG
            sta SYS_CTRL_1

            stx $c001

            stz SYS_CTRL_1

            bra loop

;
; A simple interrupt handler
;
my_handler: .proc
            pha

            ; Save the system control register
            lda SYS_CTRL_1
            pha

            ; Switch to I/O page 0
            stz SYS_CTRL_1

            ; Check for timer 1 flag
            lda #INT05_TIMER_1
            bit INT_PEND_0
            beq return              ; If it's zero, exit the handler

            ; Yes: clear the flag for timer 1
            sta INT_PEND_0

            ; Move to the text screen page
            lda #SYS_CTRL_TEXT_PG
            sta SYS_CTRL_1

            ; Increment the character at position 0
            inc $c000

            ; Restore the system control register
return:     pla
            sta SYS_CTRL_1

            ; Return to the original code
            pla
            rti
            .pend
