;;;
;;; An example demonstrating use of the SN76489 (PSG) sound chip
;;;

psg_l = $D600
psg_r = $D610

            ; Set RESET vector to kickstart the code

* = $fffc

reset:      .word <>start

* = $a000

start:      ldy #0

            ; Get the note to play
loop:       lda score,y

            ; If we're at the end of the score, we're done
            bne playnote
done:       nop
            bra done

            ; Find the frequency for the note
playnote:   sec                     ; Convert the note character to an index
            sbc #'A'                ; Into the frequency table
            tax

            lda frequency,x         ; Get the low 4 bits of the frequency
            and #$0f
            ora #$80
            sta psg_l
            sta psg_r

            lda frequency,x         ; Get the upper bits of the frequency
            lsr a
            lsr a
            lsr a
            lsr a
            and #$3f
            sta psg_l
            sta psg_r

            ; Start playing the note
            lda #$90
            sta psg_l
            sta psg_r

            ; Wait for the length of the note (1/2 second)
            ldx #3
            jsr wait_tens

            ; Stop playing the note
            lda #$9f
            sta psg_l
            sta psg_r

            ; Wait for the pause between notes (1/5 second)
            ldx #3
            jsr wait_tens

            ; Try the next note
            iny
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
;
; Assignment of notes to frequency
; NOTE: in general, this table should support 10-bit values
;       we're using just one octave here, so we can get away with bytes
;       PSG system clock is 3.57MHz
;
frequency:  .byte 127   ; A (Concert A)
            .byte 113   ; B
            .byte 212   ; C
            .byte 190   ; D
            .byte 169   ; E
            .byte 159   ; F
            .byte 142   ; G

;
; The notes to play
;
score:      .text "CCGGAAG"
            .text "FFEEDDC"
            .text "GGFFEED"
            .text "GGFFEED"
            .text "CCGGAAG"
            .text "FFEEDDC",0
