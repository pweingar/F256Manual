;;;
;;; An example showing how use line interrupts (SOL) on the C256jr
;;;

.include "../common/f256jr.asm"
.include "../common/f256_irq.asm"

VIRQ = $FFFE

LINE0 = 16                      ; Start at line 16 (first line on the text display)
LINE1 = 480 - 16                ; End on line 464 (last line of text display)

;
; RESET vector to kickstart the code
;
* = $FFFC

RESET       .word <>start

;
; Variables
;
* = $0080

state       .byte ?             ; Variable to track which color we should use

;
; Code
;
* = $e000

start:      ; Disable IRQ handling
            sei

            ; Go back to I/O page 0
            stz MMU_IO_CTRL

            ; Load my IRQ handler into the IRQ vector
            ; NOTE: this code just takes over IRQs completely. It could save
            ;       the pointer to the old handler and chain to it when it had
            ;       handled its interrupt. But what is proper really depends on
            ;       what the program is trying to do.
            lda #<my_handler
            sta VIRQ
            lda #>my_handler
            sta VIRQ+1

            ; Mask off all but the SOL interrupt
            lda #$ff
            sta INT_MASK_1
            and #~INT01_VKY_SOL
            sta INT_MASK_0

            ; Clear all pending interrupts
            lda #$ff
            sta INT_PEND_0
            sta INT_PEND_1

            ; Make sure we're in text mode
            lda #$01                ; enable TEXT
            sta VKY_MSTR_CTRL_0     ; Save that to VICKY master control register 0
            stz VKY_MSTR_CTRL_1

            ; Set the border
            lda #$01                ; Enable the border
            sta VKY_BRDR_CTRL

            lda #16                 ; Make it 16 pixels wide
            sta VKY_BRDR_VERT
            sta VKY_BRDR_HORI

            lda #$80                ; Make it cyan to start with
            sta VKY_BRDR_COL_B
            sta VKY_BRDR_COL_G
            stz VKY_BRDR_COL_R

            lda #$01                ; Turn on the line interrupt
            sta VKY_LINE_CTRL

            lda #<LINE0             ; set the line to interrupt on
            sta VKY_LINE_NBR_L
            lda #>LINE0
            sta VKY_LINE_NBR_H

            stz state               ; Start in state 0

            ; Re-enable IRQ handling
            cli

loop:       ; Just loop forever... a real program will do stuff here
            nop
            bra loop

;
; A simple interrupt handler
;
my_handler: .proc
            pha

            ; Save the system control register
            lda MMU_IO_CTRL
            pha

            ; Switch to I/O page 0
            stz MMU_IO_CTRL

            ; Check for SOL flag
            lda #INT01_VKY_SOL
            bit INT_PEND_0
            beq return              ; If it's zero, exit the handler

            ; Yes: clear the flag for SOL
            sta INT_PEND_0

            lda state               ; Check the state
            beq is_zero

            stz state               ; If state 1: Set the state to 0

            lda #<LINE0             ; Set the line to interrupt on
            sta VKY_LINE_NBR_L
            lda #>LINE0
            sta VKY_LINE_NBR_H

            lda #$80                ; Make the border blue
            sta VKY_BRDR_COL_B
            stz VKY_BRDR_COL_G
            stz VKY_BRDR_COL_R
            bra return

is_zero:    lda #$01                ; Set the state to 1
            sta state

            lda #<LINE1             ; set the line to interrupt on
            sta VKY_LINE_NBR_L
            lda #>LINE1
            sta VKY_LINE_NBR_H

            lda #$80                ; Make the border red
            sta VKY_BRDR_COL_R
            stz VKY_BRDR_COL_G
            stz VKY_BRDR_COL_B

            ; Restore the system control register
return:     pla
            sta MMU_IO_CTRL

            ; Return to the original code
            pla
            rti
            .pend
