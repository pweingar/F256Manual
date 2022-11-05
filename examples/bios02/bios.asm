;;;
;;; A simple BIOS for 65C02 machines
;;;

.include "bios02/sections.asm"
.include "common/f256jr.asm"

;;
;; Jump table
;;

.section code

boot        jmp iboot
wboot       jmp iwboot
const       jmp iconst
conin       jmp iconin
conout      jmp iconout

;
; Cold boot routine
;
iboot:      sei                     ; Disable interrupts
            cld                     ; Clear the decimal bit
            ldx #$ff                ; Reset the stack
            txs

            ;
            ; Initialize the MMU
            ;

            stz MMU_IO_CTRL         ; Set to I/O Page 0

            lda #$80                ; Edit MLUT 0
            sta MMU_MEM_CTRL

            lda #0                  ; Initialize memory LUT 0 to map in the first 64KB of RAM
            ldx #0
mmu_loop:   sta MMU_MEM_BANK_0,x
            inc a
            inx
            cpx #8
            bne mmu_loop

            stz MMU_MEM_CTRL        ; Turn of editting of MLUT 0

            jsr coninit             ; Initialize the console

;
; Lock up
;

lock:       nop
            bra lock

;
; Warm boot -- for now, just the same as BOOT
;
iwboot:     jmp boot

.include "bios02/console.asm"

;
; NMI handler
;
inmi        rti

;
; IRQ handler
;
iirq        rti

;;
;; 6502 Vectors
;;

.section vectors

vnmi        .word <>inmi
vreset      .word <>boot
virq        .word <>iirq
