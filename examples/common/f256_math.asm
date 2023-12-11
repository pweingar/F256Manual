;;;
;;; Registers for some of the integer math coprocessor
;;;

;
; Unsigned integer multiplier
;

MULU_A_L = $DE00	; Input A for unsigned multiplication
MULU_A_H = $DE01
MULU_B_L = $DE02	; Input B for unsigned multiplication
MULU_B_H = $DE03
MULU_LL = $DE10		; Result A * B
MULU_LH = $DE11
MULU_HL = $DE12
MULU_HH = $DE13