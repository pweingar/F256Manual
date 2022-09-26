;;;
;;; An example showing how to manage the interrupt controller on the C256jr
;;;

VIRQ = $FFFE

MMU_MEM_CTRL = $0000
MMU_IO_CTRL = $0001

SID_LEFT = $D400        ; Location of the first register for the left SID chip
SID_RIGHT = $D500       ; Location of the first register for the right SID chip

NOTE_A = 7346           ; Concert A = 440Hz

;
; RESET vector to kickstart the code
;
* = $FFFC

RESET       .word <>start

;
; Code
;
* = $e000

start:      stz MMU_IO_CTRL     ; Switch to I/O page 0
            jsr INIT_CODEC      ; Initialize the CODEC

;
; Turn everything off on the SIDs
;

            ldx #0
            lda #0
clr_loop:   sta SID_LEFT,x
            sta SID_RIGHT,x
            inx
            cpx #25
            bne clr_loop

;
; Set the SID volume
;

            lda #15
            sta SID_LEFT+24
            sta SID_RIGHT+24

;
; Define the ADSR envelope
;

            lda #$87            ; Attack = 8 (0.1s), Decay = 7 (80ms)
            sta SID_LEFT+5
            sta SID_RIGHT+5

            lda #$8C            ; Sustain = 15, Release = 12 (3s)
            sta SID_LEFT+6
            sta SID_RIGHT+6

;
; Set the frequency, concert A = 440Hz, n = 7217
;

            lda #<NOTE_A
            sta SID_LEFT+0
            sta SID_RIGHT+0
            lda #>NOTE_A
            sta SID_LEFT+1
            sta SID_RIGHT+1

;
; Play the note by turning on the GATE
;

            lda #$11            ; GATE + TRIANGLE
            sta SID_LEFT+4
            sta SID_RIGHT+4

;
; Wait 1 second
;

            ldx #20
            jsr wait_tens

;
; Release the note
;

            stz SID_LEFT+4
            stz SID_RIGHT+4

;
; Wait forever
;

loop:       nop
            bra loop


;
; Wait for about 1ms
;
wait_1ms:   phx
            phy

            ; Inner loop is 6 clocks per iteration or 1us
            ; Run the inner loop ~1000 times for 1ms

            ldx #3
wait_outr:  ldy #$ff
wait_inner: nop
            dey
            bne wait_inner
            dex
            bne wait_outr

            ply
            plx
            rts

;
; Wait for 100ms
;
wait_100ms: phx
            ldx #100
wait100l:   jsr wait_1ms
            dex
            bne wait100l
            plx
            rts

;
; Wait for some 10ths of seconds
;
; X = number of 10ths of a second to wait
;
wait_tens:  jsr wait_100ms
            dex
            bne wait_tens
            rts

.include "codec.asm"
