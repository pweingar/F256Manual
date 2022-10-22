;;;
;;; Example code for chapter 1
;;;
;;; How to use the MMU and print text to the screen
;;;
;;; Written for 64TASS but should be portable to other assemblers
;;;

* = $FFFC

reset:  .word <>start   ; Set the reset vector to our code to kickstart on upload

* = $1000

start:  lda #$80        ; Edit enabled, LUT#0 selected for edit
        sta $0001

        ldx #0		    ; Start at bank 0
l1:	    txa		        ; The CPU bank and System bank will be the same
        sta $0008,x     ; Set the System bank to use for this bank
        inx             ; Move to the next bank
        cpx #7		    ; Until we reach bank #7
        bne l1

        lda #$40		; CPU Bank 7 will map to System Bank $40
        sta $000f		; Set bank 7

        stz $0000		; Select LUT#0 as active, turn off editing

;
; Print an A
;

        lda $0001		; Save the current MMU setting
        pha

        lda #$02		; Swap I/O Page 2 into bank 6
        sta $0001

        lda #'f'		; Write ‘f’ to the upper left corner
        sta $C000

        pla             ; Restore the old MMU setting
        sta $0001

;
; Set up blue and yellow as colors we can use and make the A yellow on blue
;

        lda $0001		; Save the MMU state
        pha

        stz $0001		; Switch in I/O Page #0

        lda #$01        ; Make sure we're in text mode
        sta $D000
        stz $D001       ; Make sure we're in 80x60

        stz $D810		; Set foreground #4 to medium yellow
        lda #$80
        sta $D811
        sta $D812

        lda #$80		; Set background #5 to blue
        sta $D854
        stz $D855
        stz $D856

        lda #$03		; Switch to I/O page #3 (color matrix)
        sta $0001

        lda #$45		; Color will be foreground=4, background=5
        sta $C000

;
; Change 'f' to be our "fancy F"
;

        lda #$01        ; Switch to I/O page 1
        sta $0001

        ldx #0
fontlp: lda fancyf,x    ; Get the next byte of our F
        sta $c230,x     ; And write it to the position of 'F' in font memory
        inx
        cpx #8          ; Just copy 8 bytes
        bne fontlp      ; Keep looping until we're done

        pla             ; Restore the MMU state
        sta $0001

;
; Spin here forever
;
spin:   nop
        bra spin

fancyf: .byte $1F, $30, $30, $7C, $60, $C0, $C0
