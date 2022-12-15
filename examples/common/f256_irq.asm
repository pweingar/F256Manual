;
; Interrupt Controller Registers
;
INT_PEND_0 = $D660  ; Pending register for interrupts 0 - 7
INT_PEND_1 = $D661  ; Pending register for interrupts 8 - 15
INT_MASK_0 = $D66C  ; Mask register for interrupts 0 - 7
INT_MASK_1 = $D66D  ; Mask register for interrupts 8 - 15

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
