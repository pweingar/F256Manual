.cpu "w65c02"

.include "SDCard_Controller_def.asm"
.include "interrupt_def.asm"
.include "RTC_def.asm"
.include "VIA_def.asm"
.include "Simple_UART_Jr_def.asm"
.include "TinyVicky_Def.asm"
.include "C256_Jr_SID_def.asm"

VECTORS_BEGIN   = $FFFA ;0 Byte  Interrupt vectors
VECTOR_NMI      = $FFFA ;2 Bytes Emulation mode interrupt handler
VECTOR_RESET    = $FFFC ;2 Bytes Emulation mode interrupt handler
VECTOR_IRQ      = $FFFE ;2 Bytes Emulation mode interrupt handler

ISR_BEGIN       = $FF00 ; Byte  Beginning of CPU vectors in Direct page
HRESET          = $FF00 ;16 Bytes Handle RESET asserted. Reboot computer and re-initialize the kernel.
HCOP            = $FF10 ;16 Bytes Handle the COP instruction. Program use; not used by OS
HBRK            = $FF20 ;16 Bytes Handle the BRK instruction. Returns to BASIC Ready prompt.
HABORT          = $FF30 ;16 Bytes Handle ABORT asserted. Return to Ready prompt with an error message.
HNMI            = $FF40 ;32 Bytes Handle NMI
HIRQ            = $FF60 ;32 Bytes Handle IRQ
; Zero Page Definition
KEYBOARD_SC_TMP = $20 
; Keyboard
OUT_BUF_FULL    = $01
INPT_BUF_FULL	= $02
SYS_FLAG	    = $04
CMD_DATA		= $08
KEYBD_INH       = $10
TRANS_TMOUT	    = $20
RCV_TMOUT		= $40
PARITY_EVEN		= $80
INH_KEYBOARD	= $10
KBD_ENA         = $AE
KBD_DIS			= $AD
;Keyboard $D640 - $D64F
STATUS_PORT 	= $D644;
KBD_CMD_BUF 	= $D644;
KBD_OUT_BUF 	= $D640;
KBD_INPT_BUF 	= $D640;
KBD_DATA_BUF 	= $D640;
; IO PAGE 0
TEXT_LUT_FG      = $D800
TEXT_LUT_BG		 = $D840
; Text Memory
TEXT_MEM         = $C000 	; IO Page 2
COLOR_MEM        = $C000 	; IO Page 3
DIPSWITCH        = $D670
; CODEC 
CODEC_LOW        = $D620
CODEC_HI         = $D621
CODEC_CTRL       = $D622
; IEC
; When Writting
; The FIFO Write/Command is 512Bytes Deep
TALKER_CMD      = $D680     ; Write all Command here, save $3F, $5F
TALKER_CMD_LAST = $D681     ; This is for $3F or $5F Only
TALKER_DTA      = $D682     ; Any other data, write here
TALKER_DTA_LAST = $D683     ; Write to this address for the last data to send
; Reading       
LISTNER_DTA     = $D680     ; Read Data From FIFO
LISTNER_FIFO_STAT   = $D681 ; The FIFO Read Size is 512bytes
; Bit[0] Read FIFO Empty Flag (1 = Empty, 0 = Data in FIFO)
; Bit[1] Read Full Flag ( 1 = Full, 0 = Space Left)
; Bit[2] Last Byte Flag ( 1 = This is the last byte of the packet) - Check after reading the Data from FIFO - (updated at the time of read)
; Bit[3] Not used
; Bit[4] Device Not Preset (Send the Command $28 or $48, then check this flag before sending the next command) ( 1 = No Device Attached)
; Bit[5] Not used
; Bit[6] Not used
; Bit[7] Not used
LISTNER_FIFO_CNT_LO = $D682 
; Bit[7:0] = READ FIFO Count [7:0]
LISTNER_FIFO_CNT_HI = $D683 
; Bit[0] = READ FIFO Count [8]

* = $8000
;POOYAN_TILE_SET
;.binary "Graphics/SplashJr.data.pal", 0, 1024	
; A000 to C400
.binary "Graphics/Pooyan/pooyan-tileset.bin",0, 9216
* = $A400 
.binary "Graphics/Pooyan/pooyan-Tilemap.tlm",0, 2402


; RAM Block 0 0000-1FFF - MMU Address $08
; RAM Block 1 2000-3FFF - MMU Address $09
; RAM Block 2 4000-5FFF - MMU Address $0A
; RAM Block 3 6000-7FFF - MMU Address $0B
; RAM Block 4 8000-9FFF - MMU Address $0C
; RAM Block 5 A000-BFFF - MMU Address $0D
; RAM Block 6 - Not Visible because of IO - M
; FLASH Block 0 - E000-FFFF - MMU Address $0F



* = $E000

IBOOT           ; boot the system
                CLC           		; clear the carry flag
                SEI					; No Interrupt now baby
				LDX #$FF 			; Let's push that stack pointer right up there
				TXS

                lda $0F
                lda #$80
                sta $00
                lda $0F
                lda #$08
                sta $0A 

                lda #$01
                ldx #$00
testfill                
                sta $4000, X
                sta $4100, X
                sta $4200, X
                sta $4300, X
                inx 
                bne testfill
                
                ;lda #$AA
                ;sta $8000
                ;lda #$55
                ;sta $813F
                ;lda $8004
                LDA #$FF
                ; Setup the EDGE Trigger 
                STA INT_EDGE_REG0
                STA INT_EDGE_REG1
                ; Mask all Interrupt @ This Point
                STA INT_MASK_REG0
                STA INT_MASK_REG1
                ; Clear both pending interrupt
                lda INT_PENDING_REG0
                sta INT_PENDING_REG0
                lda INT_PENDING_REG1
                sta INT_PENDING_REG1               

									; --- LET'S BEGIN --- 
				jsr SetIOPage0		; The Color LUT for the Text Mode is in Page 0
                lda DIPSWITCH
                jsr TinyVky_Init
                jsr INIT_CODEC      ; Make sure to setup the CODEC Very early
                jsr PSG_MUTE
                lda #$0C
                sta RTC_CTRL
                lda RTC_CTRL
                lda #$11
                sta RTC_SEC
                lda #$04
                sta RTC_CTRL
                lda RTC_SEC
				jsr Init_Text_LUT	; Init the Text Color Table

                ; Set the VIA in Input (prolly the mode it is already in)
                lda #$00 
                sta VIA_DDRB
                sta VIA_DDRA

                lda VIA_ORB_IRB

                LDA #$55
                sta UART_SR
                lda UART_SR
                jsr INIT_SERIAL
                lda #'J'
                jsr UART_PUTC
                lda #'R'
                jsr UART_PUTC
                lda #'.'
                jsr UART_PUTC                                
                ; Set the Backgroud Color
				jsr SetIOPage3		;
                jsr Fill_Color                
                ; Fill the Screen with Spaces
                jsr SetIOPage2		;
                jsr Clear_Screen    ;
                ; Display Something on Screen

                jsr SplashText
				jsr SetIOPage0
                ; Init Devices      ; Let's Init the Keyboard first
                lda #$55
                sta KBD_INPT_BUF
                jsr INITKEYBOARD     ; Need to tune


                jsr READ_MBR_SDCARD
                lda #$80
                sta $10
                lda #$C2
                sta $11 
                lda #$F0
                sta $12
                lda #$13
                sta $13                
                jsr MEM_2_DSP_HEX16

                ; Let's try a split Border
                ;
                ;lda #200
                ;sta VKY_LINE_CMP_VALUE_LO
                ;lda #0
                ;sta VKY_LINE_CMP_VALUE_HI
                ;lda #$01 
                ;sta VKY_LINE_IRQ_CTRL_REG
                ;SEI
                ;lda INT_PENDING_REG0  ; Read the Pending Register &
                ;and #JR0_INT01_SOL
                ;sta INT_PENDING_REG0  ; Writing it back will clear the Active Bit
                ; remove the mask
                ;lda INT_MASK_REG0
                ;and #~JR0_INT01_SOL
                ;sta INT_MASK_REG0

                ;lda INT_PENDING_REG0  ; Read the Pending Register &
                ;and #JR0_INT02_KBD
                ;sta INT_PENDING_REG0  ; Writing it back will clear the Active Bit
                ; remove the mask
                ;lda INT_MASK_REG0
                ;and #~JR0_INT02_KBD
                ;sta INT_MASK_REG0                


                ; VICKY - Bitmap Code test
                lda #( Mstr_Ctrl_Graph_Mode_En | Mstr_Ctrl_Bitmap_En | Mstr_Ctrl_TileMap_En | Mstr_Ctrl_Sprite_En | Mstr_Ctrl_Text_Mode_En | Mstr_Ctrl_Text_Overlay )
                ;lda #( Mstr_Ctrl_Graph_Mode_En | Mstr_Ctrl_Bitmap_En | Mstr_Ctrl_TileMap_En | Mstr_Ctrl_Sprite_En )
                ;lda #( Mstr_Ctrl_Graph_Mode_En | Mstr_Ctrl_Bitmap_En )                
                sta MASTER_CTRL_REG_L
                
                lda #$00
                sta MASTER_CTRL_REG_H
                lda #$00
                sta BORDER_CTRL_REG
                lda #$00
                sta BACKGROUND_COLOR_B
                sta BACKGROUND_COLOR_G
                sta BACKGROUND_COLOR_R
                ; put some values in the LUT for graphic use
                jsr SetIOPage1
                ldx #$00
KeepFilling0
                lda LUT,x
                sta TyVKY_LUT0,x
                lda LUT+$0100,x
                sta TyVKY_LUT0+$0100,x
                lda LUT+$0200,x
                sta TyVKY_LUT0+$0200,x
                lda LUT+$0300,x
                sta TyVKY_LUT0+$0300,x
                inx 
                cpx #$00
                bne KeepFilling0

                jsr SetIOPage0
                ; These are to setup the Layer Attributes
                lda #$04
                sta VKY_RESERVED_00
                lda #$02
                sta VKY_RESERVED_01

                jsr Setup_Sprites_Test
                jsr Setup_Tile_Test

                lda #$00
                sta TyVKY_BM0_START_ADDY_L
                lda #$00
                sta TyVKY_BM0_START_ADDY_M
                lda #$01
                sta TyVKY_BM0_START_ADDY_H
                lda #$01
                sta TyVKY_BM0_CTRL_REG

                lda #$00
                sta TyVKY_BM1_START_ADDY_L
                lda #$00
                sta TyVKY_BM1_START_ADDY_M
                lda #$02
                sta TyVKY_BM1_START_ADDY_H
                lda #$00    
                sta TyVKY_BM1_CTRL_REG        

                lda #$00
                sta TyVKY_BM2_START_ADDY_L
                lda #$00
                sta TyVKY_BM2_START_ADDY_M
                lda #$03
                sta TyVKY_BM2_START_ADDY_H
                lda #$00  
                sta TyVKY_BM2_CTRL_REG                    

                ;jsr Read_Drive_Status
                ;jsr test_IEC
                ;jsr SID_Test_Chime;
                ;jsr PSG_TEST;
DONE				
				JMP DONE
				



Init_Text_LUT
				LDX	#$00
lutinitloop0	LDA fg_color_lut,x		; get Local Data
                sta TEXT_LUT_FG,x	; Write in LUT Memory
                inx
                cpx #$40
                bne lutinitloop0
                ; Set Background LUT Second
                LDX	#$00
lutinitloop1	LDA bg_color_lut,x		; get Local Data
                STA TEXT_LUT_BG,x	; Write in LUT Memory
                INX
                CPX #$40
                bne lutinitloop1
				RTS

SetIOPage0		
		
				lda $01		; Load Page Control Register
				and #$FC    ; isolate 2 first bit 
				sta $01     ; Write back to make sure we are on page 0
				rts 

SetIOPage1		
				lda #$01		; Load Page Control Register
				;and #$FC    ; isolate 2 first bit 
				;ora #$01
				sta $01     ; Write back to make sure we are on page 0
				rts 

SetIOPage2		
				lda $01		; Load Page Control Register
				and #$FC    ; isolate 2 first bit 
				ora #$02
				sta $01     ; Write back to make sure we are on page 0
				rts 

SetIOPage3		
				lda $01		; Load Page Control Register
				and #$FC    ; isolate 2 first bit 
				ora #$03
				sta $01     ; Write back to make sure we are on page 0
				rts 

Clear_Screen    ldx #$00
                lda #$00
                sta $10
                lda #$C0
                sta $11 

                ldy #$00
ClSC_Loopa                        
                lda #$20 
ClSC_Loopy                
                sta ($10),y 
                iny 
                cpy #$00 
                bne ClSC_Loopy
                lda $11
                inc a 
                sta $11
                cmp #$D3 
                bne ClSC_Loopa
                rts 


Fill_Color      ldx #$00
                lda #$00
                sta $10
                lda #$C0
                sta $11 

                ldy #$00
FlCo_Loopa                        
                lda #$E1 
FlCo_Loopy                
                sta ($10),y 
                iny 
                cpy #$00 
                bne FlCo_Loopy
                lda $11
                inc a 
                sta $11
                cmp #$D3 
                bne FlCo_Loopa
                rts 

;;; 
SplashText      lda #$00
                sta $10
                lda #$C0
                sta $11 
                lda #<Text2Display
                sta $12
                lda #>Text2Display
                sta $13
PrintText
                ldy #$00
SpText_Loopy      
                lda ($12),y
                ;and #$BF ; This is when PETSCII is used
                cmp #$00
                beq EndSplash
                sta ($10),y 
                iny 
                cpy #$00 
                bne SpText_Loopy
                inc $11 
                inc $13
                bne SpText_Loopy
EndSplash                
                rts       


MEM_2_DSP_HEX16
                jsr SetIOPage2		;
                ldy #$00
                ldx #$00
HexDisplayLoop     
                lda ($12)     ; Source 
                and #$F0 
                lsr a
                lsr a
                lsr a
                lsr a
                phx 
                tax 
                lda HEX, X
                sta ($10),y     ; Destination
                iny 
                lda ($12)     ; Source 
                and #$0F 
                tax 
                lda HEX, X
                sta ($10),y     ; Destination
                iny 
                lda #$20
                sta ($10),y     ; Destination
                iny
                inc $12
                plx 
                inx 
                cpx #$10
                bne HexDisplayLoop      
                jsr SetIOPage0		;                          
                rts  


Poll_Inbuf	    lda STATUS_PORT		; Load Status Byte
				and	#INPT_BUF_FULL	; Test bit $02 (if 0, Empty)
				cmp #INPT_BUF_FULL
				beq Poll_Inbuf
                rts

Poll_Outbuf     lda STATUS_PORT
                and #OUT_BUF_FULL ; Test bit $01 (if 1, Full)
                cmp #OUT_BUF_FULL
                bne Poll_Outbuf
                rts

INITKEYBOARD	clc
                ; Test AA
			    lda #$AA			;Send self test command
				sta KBD_CMD_BUF
								;; Sent Self-Test Code and Waiting for Return value, it ought to be 0x55.
                jsr Poll_Outbuf ;

		        lda KBD_OUT_BUF		;Check self test result
		        cmp #$55
		        beq	passAAtest

                jmp initkb_loop_out

passAAtest      jsr SetIOPage2		;
                lda #$31
                sta $C000 
                jsr SetIOPage0
                ;; Test AB

                jsr Poll_Inbuf
				lda #$AB			;Send test Interface command
				sta KBD_CMD_BUF
                jsr Poll_Outbuf ;
TryAgainAB:
				lda KBD_OUT_BUF		;Display Interface test results
				cmp #$00			;Should be 00
				beq	passABtest
                bne TryAgainAB

                jsr SetIOPage2		;
                lda #$23
                sta $C005
                jsr SetIOPage0
                jmp initkb_loop_out

passABtest      jsr SetIOPage2		;
                lda #$32
                sta $C001
                jsr SetIOPage0

;; Program the Keyboard & Enable Interrupt with Cmd 0x60
                lda #$60            ; Send Command 0x60 so to Enable Interrupt
                sta KBD_CMD_BUF
                jsr Poll_Inbuf ;
                lda #%01000001      ; Enable Interrupt
                ;LDA #%01001001      ; Enable Interrupt for Mouse and Keyboard
                sta KBD_DATA_BUF
                
                jsr SetIOPage2		;
                lda #$33
                sta $C002
                jsr SetIOPage0
; Reset Keyboard
               jsr Poll_Inbuf;
                lda #$FF      ; Send Keyboard Reset command
                sta KBD_DATA_BUF
                ; Must wait here;
                
                 ldy #$FF 
DLY_LOOP2       ldx #$FF
DLY_LOOP1       dex
                nop
                nop
                nop
                nop
                cpx #$00
                bne DLY_LOOP1
                dey 
                cpy #$00 
                bne DLY_LOOP2
                nop
;endless                jmp endless
                jsr Poll_Outbuf ;

                lda KBD_OUT_BUF   ; Read Output Buffer

                jsr SetIOPage2		;
                lda #$34
                sta $C003
                jsr SetIOPage0
DO_CMD_F4_AGAIN
                jsr Poll_Inbuf ;
				lda #$F4			; Enable the Keyboard
				sta KBD_DATA_BUF
                jsr Poll_Outbuf ;

				lda KBD_OUT_BUF		; Clear the Output buffer
;                cmp #$FA
;                bne DO_CMD_F4_AGAIN


                lda #<Success_Kbd        ; $12/$13 Source
                sta $12
                lda #>Success_Kbd
                sta $13
                lda #$E0
                sta $10
                lda #$C1
                sta $11
                jsr SetIOPage2		;                
                jsr PrintText
                jsr SetIOPage0		;                
                rts

initkb_loop_out lda #<Failed_Kbd        ; $12/$13 Source
                sta $12
                lda #>Failed_Kbd
                sta $13
                lda #$30
                sta $10
                lda #$C2
                sta $11
                jsr SetIOPage2		;                
                jsr PrintText
                jsr SetIOPage0		;                
                rts
;/////////////////////////
;// SDCARD
;/////////////////////////
READ_MBR_SDCARD
                jsr SetIOPage0		; Just make sure we are in the right page... You never know!
                lda #$01
                sta SDC_TRANS_TYPE_REG  ; Set Init SD


                lda #$01
                sta SDC_TRANS_CONTROL_REG ; Let's Start the Process

SDC_NOT_FINISHED:
                lda SDC_TRANS_STATUS_REG
                and #SDC_TRANS_BUSY
                cmp #SDC_TRANS_BUSY
                beq SDC_NOT_FINISHED

                lda SDC_TRANS_ERROR_REG
                and #$3F
                sta $1000
                cmp #$00
                beq SDISREADY
                ;; Here be errors
                lda #<Failed_SDC        ; $12/$13 Source
                sta $12
                lda #>Failed_SDC
                sta $13
                lda #$30
                sta $10
                lda #$C2
                sta $11
                jsr SetIOPage2		;                
                jsr PrintText
                jsr SetIOPage0		;  
                rts
                ; I guess if we make it here, it actually worked.
SDISREADY
                lda #$00
                sta SDC_SD_ADDR_7_0_REG
                lda #$00
                sta SDC_SD_ADDR_15_8_REG
                lda #$00
                sta SDC_SD_ADDR_23_16_REG
                lda #$00
                sta SDC_SD_ADDR_31_24_REG

                lda #SDC_TRANS_READ_BLK
                sta SDC_TRANS_TYPE_REG

                lda #$01
                sta SDC_TRANS_CONTROL_REG ; Let's Start the Process

SDC_NOT_FINISHED2:
                lda SDC_TRANS_STATUS_REG
                and #SDC_TRANS_BUSY
                cmp #SDC_TRANS_BUSY
                beq SDC_NOT_FINISHED2

                lda SDC_TRANS_ERROR_REG
                sta $1001

                lda SDC_RX_FIFO_DATA_CNT_LO
                sta $1002
                lda SDC_RX_FIFO_DATA_CNT_HI
                sta $1003
                ldx #$00
SDC_LOAD_BLOCK0:
                lda SDC_RX_FIFO_DATA_REG
                sta $1200, X
                INX
                CPX #$00
                BNE SDC_LOAD_BLOCK0
                LDX #$00
SDC_LOAD_BLOCK1:
                lda SDC_RX_FIFO_DATA_REG
                sta $1300, X
                INX
                CPX #$00
                BNE SDC_LOAD_BLOCK1
                ; Here be success
                lda #<Success_SDC        ; $12/$13 Source
                sta $12
                lda #>Success_SDC
                sta $13
                lda #$80
                sta $10
                lda #$C2
                sta $11
                jsr SetIOPage2		;                
                jsr PrintText
                jsr SetIOPage0		;  
                rts

;/////////////////////////
;// SERIAL
;/////////////////////////
INIT_SERIAL	.proc
	
			; Init Baud Rate
			lda UART_LCR
			ora #LCR_DLB
			sta UART_LCR
			lda UART_LCR

			lda #$00
			sta UART_DLH
			lda #13			; (25.125Mhz / (16 * 115200)) = 13.65 (internal speed of Devices inside FPGA is 25.175Mhz (not 6Mhz))
			sta UART_DLL
			
			lda UART_LCR
			eor #LCR_DLB
			sta UART_LCR	
			; Init Serial Parameters
			lda #LCR_PARITY_NONE | LCR_STOPBIT_1 | LCR_DATABITS_8
			and #$7F
			sta UART_LCR
	
			lda #%11000001	; FIFO Mode is always On and it has only 14Bytes
			sta UART_FCR
			rts

.pend
;
; Send a byte to the UART
;
; Inputs:
;   A = the character to print
;
UART_PUTC   .proc
               ; Wait for the transmit FIFO to free up
            pha 
wait_putc   lda UART_LSR
            and #LSR_XMIT_EMPTY
            beq wait_putc
			pla 
            sta UART_TRHB
            rts
.pend
;/////////////////////////
;// CODEC
;/////////////////////////
;CODEC_LOW        = $D620
;CODEC_HI         = $D621
;CODEC_CTRL       = $D622
INIT_CODEC 
            ;                LDA #%00011010_00000000     ;R13 - Turn On Headphones
            lda #%00000000
            sta CODEC_LOW
            lda #%00011010
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ; LDA #%0010101000000011       ;R21 - Enable All the Analog In
            lda #%00000011
            sta CODEC_LOW
            lda #%00101010
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ; LDA #%0010001100000001      ;R17 - Enable All the Analog In
            lda #%00000001
            sta CODEC_LOW
            lda #%00100011
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ;   LDA #%0010110000000111      ;R22 - Enable all Analog Out
            lda #%00000111
            sta CODEC_LOW
            lda #%00101100
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ; LDA #%0001010000000010      ;R10 - DAC Interface Control
            lda #%00000010
            sta CODEC_LOW
            lda #%00010100
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ; LDA #%0001011000000010      ;R11 - ADC Interface Control
            lda #%00000010
            sta CODEC_LOW
            lda #%00010110
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ; LDA #%0001100111010101      ;R12 - Master Mode Control
            lda #%01000101
            sta CODEC_LOW
            lda #%00011000
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            rts

CODEC_WAIT_FINISH
CODEC_Not_Finished:
            lda CODEC_CTRL
            and #$01
            cmp #$01 
            beq CODEC_Not_Finished
            rts 

TinyVky_Init:
            lda # Mstr_Ctrl_Text_Mode_En;
            sta MASTER_CTRL_REG_L
            lda MASTER_CTRL_REG_L
            lda #Border_Ctrl_Enable
            sta BORDER_CTRL_REG
            lda #$FF ;AAFFEE
            sta BORDER_COLOR_B
            lda #$88 ;AAFFEE
            sta BORDER_COLOR_G           
            lda #$00
            sta BORDER_COLOR_R
            lda #16
            sta BORDER_X_SIZE
            sta BORDER_Y_SIZE
            lda #Vky_Cursor_Enable | Vky_Cursor_Flash_Rate1 
            sta VKY_TXT_CURSOR_CTRL_REG
            lda #160
            sta VKY_TXT_CURSOR_CHAR_REG
            lda #28
            sta VKY_TXT_CURSOR_COLR_REG
            lda #0
            sta VKY_TXT_CURSOR_X_REG_L
            sta VKY_TXT_CURSOR_X_REG_H
            sta VKY_TXT_CURSOR_Y_REG_H
            lda #5
            sta VKY_TXT_CURSOR_Y_REG_L
            rts
;
; Wait for about 1ms
;
WAIT_1MS:   phx
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
WAIT_100ms: phx
            ldx #100
WAIT100L:   jsr WAIT_1MS
            dex
            bne WAIT100L
            plx
            rts

;
; Wait for some 10ths of seconds
;
; X = number of 10ths of a second to wait
;
WAIT_TENS:  jsr WAIT_100ms
            dex
            bne WAIT_TENS
            rts

;
; Print a trace message for the SID test on the second line
;
SID_TRACE:  phx
            pha
            jsr SetIOPage2
            pla
            plx
            sta $c050,x
            jsr SetIOPage0
            rts

SID_Test_Chime:
            lda #$29
            ; Left
            sta SID_L_V1_ATCK_DECY
            sta SID_L_V2_ATCK_DECY
            sta SID_L_V3_ATCK_DECY
            ;Right
            sta SID_R_V1_ATCK_DECY
            sta SID_R_V2_ATCK_DECY
            sta SID_R_V3_ATCK_DECY
            ; left
            lda #$1F
            sta SID_L_V1_SSTN_RLSE
            sta SID_L_V2_SSTN_RLSE
            sta SID_L_V3_SSTN_RLSE
            ; Right
            sta SID_R_V1_SSTN_RLSE
            sta SID_R_V2_SSTN_RLSE
            sta SID_R_V3_SSTN_RLSE

            lda #$0F
            sta SID_L_MODE_VOL
            sta SID_R_MODE_VOL

            ; Voice 1 - F-3
            lda #96
            sta SID_L_V1_FREQ_LO
            sta SID_R_V1_FREQ_LO
            lda #22
            sta SID_L_V1_FREQ_HI
            sta SID_R_V1_FREQ_HI

            lda #$11
            sta SID_L_V1_CTRL
            sta SID_R_V1_CTRL

            ldx #0
            lda #'0'
            jsr SID_TRACE

            ; Small Delays Here
            ldx #1
            jsr WAIT_TENS

            ; Voice 2
            lda #49
            sta SID_L_V2_FREQ_LO
            sta SID_R_V2_FREQ_LO
            lda #08
            sta SID_L_V2_FREQ_HI
            sta SID_R_V2_FREQ_HI

            lda #$11
            sta SID_L_V2_CTRL
            sta SID_R_V2_CTRL

            ldx #1
            lda #'1'
            jsr SID_TRACE

            ; Small Delay here
            ldx #1
            jsr WAIT_TENS

            ; Voice 3
            lda #135
            sta SID_L_V3_FREQ_LO
            sta SID_R_V3_FREQ_LO
            lda #33
            sta SID_L_V3_FREQ_HI
            sta SID_R_V3_FREQ_HI

            lda #$11
            sta SID_L_V3_CTRL
            sta SID_R_V3_CTRL

            ldx #2
            lda #'2'
            jsr SID_TRACE

            ; Longer Delay here
            ldx #10
            jsr WAIT_TENS

            lda #$10
            sta SID_L_V1_CTRL
            sta SID_R_V1_CTRL

            ldx #3
            lda #'3'
            jsr SID_TRACE

            ; Small Delay here
            ldx #1
            jsr WAIT_TENS

            lda #$10
            sta SID_L_V2_CTRL
            sta SID_R_V2_CTRL

            ldx #4
            lda #'4'
            jsr SID_TRACE

            ; Small Delay here
            ldx #1
            jsr WAIT_TENS

            lda #$10
            sta SID_L_V3_CTRL
            sta SID_R_V3_CTRL

            ldx #5
            lda #'5'
            jsr SID_TRACE

            ;small delay here
            ldx #1
            jsr WAIT_TENS

            lda #$00
            sta SID_L_MODE_VOL
            sta SID_R_MODE_VOL

            ldx #6
            lda #'6'
            jsr SID_TRACE

            rts

PSG_INT_L_PORT = $D600          ; Control register for the SN76489
PSG_INT_R_PORT = $D610          ; Control register for the SN76489

;
; Turn off both PSG "chips"
;
PSG_MUTE:   jsr SetIOPage0
            lda #$9f            ; Mute channel #0 (1001111)
            sta PSG_INT_L_PORT
            sta PSG_INT_R_PORT

            lda #$bf            ; Mute channel #2 (1011111)
            sta PSG_INT_L_PORT
            sta PSG_INT_R_PORT

            lda #$df            ; Mute channel #3 (1101111)
            sta PSG_INT_L_PORT
            sta PSG_INT_R_PORT

            lda #$ff            ; Mute channel #4 (1111111)
            sta PSG_INT_L_PORT
            sta PSG_INT_R_PORT

            rts

;
; Try to play a note on the PSG
;
PSG_TEST:   jsr PSG_MUTE        ; Make sure the PSGs are silent

            ;ldx #0
            ;lda #'0'
            ;jsr SID_TRACE

            ; note_code = CLK_ref / (32 * freq)
            ; where freq is the desired frequency (e.g. 440 for concert A)
            ;       CLK_ref is the frequency of the reference clock in Hz
            ;
            ; e.g. 3,146,875Hz clock, 440 frequency:
            ; note_code = 3,146,875Hz / (32 * 440Hz)
            ;           = 223 ($DF)
            lda #$83                ; Frequency bits 3..0
            sta PSG_INT_L_PORT
            sta PSG_INT_R_PORT

            lda #$12                ; Frequency bits 9..4
            sta PSG_INT_L_PORT
            sta PSG_INT_R_PORT

            lda #$90                ; Full volume
            sta PSG_INT_L_PORT
            sta PSG_INT_R_PORT

            ldx #10                 ; Wait around a second
            jsr WAIT_TENS

            ldx #1
            lda #'1'
            jsr SID_TRACE

            jsr PSG_MUTE            ; Turn off the PSG sounds
            rts


Read_Drive_Status
            ldx #$00
            lda #$48
            sta TALKER_CMD
            lda #$6F
            sta TALKER_CMD
            lda #$5F
            sta TALKER_CMD_LAST 
Not_The_Last_Byte_Rx:
FIFO_Empty_Still:
            lda LISTNER_FIFO_STAT       
            and #$01
            cmp #$01
            beq FIFO_Empty_Still     
            ; There is a Byte the FIFO go read it
            lda LISTNER_DTA
            and #$BF 
            pha 
            jsr SetIOPage2		;
            pla 
            sta $C320, x    ; Store it in the buffer
            jsr SetIOPage0		;            
            inx
            lda LISTNER_FIFO_STAT ; Read the Stat Again, because Last Bit has been updated when you read a byte out FiFo
            and #$80
            cmp #$80
            bne Not_The_Last_Byte_Rx
            ; if get here, it is because we read the last byte and we are done.

            
            rts            


test_IEC
            ldx #$00
            ;IEC Test 
            ; Send the command                
            lda #$28
            sta TALKER_CMD
            lda #$F0 
            sta TALKER_CMD
            lda #'$' 
            sta TALKER_DTA_LAST    
            lda #$3F
            sta TALKER_CMD_LAST
            ; go read the data 

            lda #$48
            sta TALKER_CMD
            lda #$60
            sta TALKER_CMD
            lda #$5F
            sta TALKER_CMD_LAST
Not_The_Last_Byte_RxDir:
FIFO_Empty_StillDir:
            lda LISTNER_FIFO_STAT       
            and #$01
            cmp #$01
            beq FIFO_Empty_StillDir     
            ; There is a Byte the FIFO go read it
            lda LISTNER_DTA
            and #$BF 
            pha 
            jsr SetIOPage2		;
            pla 
            sta $C320, x    ; Store it in the buffer of your choice
            jsr SetIOPage0		;            
            inx
            lda LISTNER_FIFO_STAT ; Read the Stat Again, because Last Bit has been updated when you read a byte out FiFo
            and #$80
            cmp #$80
            bne Not_The_Last_Byte_RxDir
            ; Close the transaction
            lda #$28
            sta TALKER_CMD
            lda #$E0 
            sta TALKER_CMD
            lda #$3F
            sta TALKER_CMD_LAST
            rts

Setup_Sprites_Test ; Setup Sprites in Different sizes
            ; Set the first Sprite to be 32x32 (Foenix Size)
            ldx #$00
First_Sprite_Fill                   
            lda #$05     
            sta $2300,X
            lda #$09     
            sta $2200,X
            lda #$07    
            sta $2100,X
            lda #$08     
            sta $2000,X
            inx 
            bne First_Sprite_Fill 

            lda # ( SPRITE_Ctrl_Enable )
            sta SP0_Ctrl
            ; Set the Pointer to $010000
            lda #$00
            sta SP0_Addy_L
            lda #$20
            sta SP0_Addy_M
            lda #$00 
            sta SP0_Addy_H
            lda #64         ; Position the sprite @ 64x64 which should be visible x:32 y:32
            sta SP0_X_L     ; Since x:0, y:0 is outside the screen
            sta SP0_Y_L
            lda #00
            sta SP0_X_H
            sta SP0_Y_H
            ; Set the second sprite to be 24x21 (C64 size)
            lda # ( SPRITE_Ctrl_Enable | SPRITE_SIZE0 | SPRITE_DEPTH0  )
            sta SP1_Ctrl
            ; Set the Pointer to $010400
            lda #$00
            sta SP1_Addy_L
            lda #$20                       
            sta SP1_Addy_M
            lda #$00 
            sta SP1_Addy_H
            lda #128         ; Position the sprite @ 64x64 which should be visible x:32 y:32
            sta SP1_X_L     ; Since x:0, y:0 is outside the screen
            lda #80            
            sta SP1_Y_L
            lda #00
            sta SP1_X_H
            sta SP1_Y_H
            ; 16x16
            lda # ( SPRITE_Ctrl_Enable | SPRITE_SIZE1 )
            sta SP2_Ctrl
            ; Set the Pointer to $010400
            lda #$00
            sta SP2_Addy_L
            lda #$20                       
            sta SP2_Addy_M
            lda #$00 
            sta SP2_Addy_H
            lda #192         ; Position the sprite @ 64x64 which should be visible x:32 y:32
            sta SP2_X_L     ; Since x:0, y:0 is outside the screen
            lda #64            
            sta SP2_Y_L
            lda #00
            sta SP2_X_H
            sta SP2_Y_H
            ; 8x8
            lda # ( SPRITE_Ctrl_Enable | SPRITE_SIZE1 | SPRITE_SIZE0)
            sta SP3_Ctrl
            ; Set the Pointer to $010400
            lda #$00
            sta SP3_Addy_L
            lda #$20                       
            sta SP3_Addy_M
            lda #$00 
            sta SP3_Addy_H
            lda #00         ; Position the sprite @ 64x64 which should be visible x:32 y:32
            sta SP3_X_L     ; Since x:0, y:0 is outside the screen
            lda #$01
            sta SP3_X_H            
            lda #64            
            sta SP3_Y_L
            lda #00            
            sta SP3_Y_H              
            rts


Setup_Tile_Test ; Setup Tile Maps 
            ; Setup where the graphics will be $0A000
            lda #$00
            sta TILE_MAP_ADDY0_L
            lda #$80 
            sta TILE_MAP_ADDY0_M
            lda #$00    ; The last nibble is the config bit bit [23] = 256x256
            sta TILE_MAP_ADDY0_H            
            lda #$08    ; The last nibble is the config bit bit [23] = 256x256
            sta TILE_MAP_ADDY0_CFG           

            ; Setup where the map is
            lda #$00
            sta TL0_START_ADDY_L
            sta TL0_START_ADDY_H
            lda #$A4 
            sta TL0_START_ADDY_M
            lda #$00
            sta TL0_MAP_X_SIZE_H
            sta TL0_MAP_Y_SIZE_H
            lda #40
            sta TL0_MAP_X_SIZE_L
            lda #32
            sta TL0_MAP_Y_SIZE_L
            lda #$00
            sta TL0_MAP_X_POS_H
            sta TL0_MAP_Y_POS_H
            lda #0
            sta TL0_MAP_X_POS_L
            lda #0            
            sta TL0_MAP_Y_POS_L

            lda #( TILE_Enable | TILE_SIZE )
            sta TL0_CONTROL_REG
            rts



* = $F400
LUT
;.binary "Graphics/SplashJr.data.pal", 0, 1024	
.binary "Graphics/PixelArtExample_320x240.data.pal",0, 1024
;.binary "Graphics/Pooyan/pooyan.pal", 0, 1024

; DATA                           
* = $F800
fg_color_lut	.text $00, $00, $00, $FF
                .text $00, $00, $80, $FF
                .text $00, $80, $00, $FF
                .text $80, $00, $00, $FF
                .text $00, $80, $80, $FF
                .text $80, $80, $00, $FF
                .text $80, $00, $80, $FF
                .text $80, $80, $80, $FF
                .text $00, $45, $FF, $FF
                .text $13, $45, $8B, $FF
                .text $00, $00, $20, $FF
                .text $00, $20, $00, $FF
                .text $20, $00, $00, $FF
                .text $20, $20, $20, $FF
                .text $FF, $80, $00, $FF
                .text $FF, $FF, $FF, $FF

bg_color_lut	  .text $00, $00, $00, $FF  ;BGRA
                .text $AA, $00, $00, $FF
                .text $00, $80, $00, $FF
                .text $00, $00, $80, $FF
                .text $00, $20, $20, $FF
                .text $20, $20, $00, $FF
                .text $20, $00, $20, $FF
                .text $20, $20, $20, $FF
                .text $1E, $69, $D2, $FF
                .text $13, $45, $8B, $FF
                .text $00, $00, $20, $FF
                .text $00, $20, $00, $FF
                .text $40, $00, $00, $FF
                .text $10, $10, $10, $FF
                .text $40, $40, $40, $FF
                .text $FF, $FF, $FF, $FF
* = $F880 
Text2Display    .text "                                                                                "
                .text "                ****    C256 FOENIX JUNIOR BASIC V2    ****                     "
                .text "                                                                                "
                .text "                  256K RAM SYSTEM 253952 BASIC BYTES FREE                       "
                .text "                                                                                "
                .text "READY.", $00

Failed_Kbd      .text "THE PS2 INIT FAILED", $00
Success_Kbd     .text "THE PS2 INIT SUCCEEDED", $00
Failed_SDC      .text "THE SDCARD FAILED", $00
Success_SDC      .text "THE SDCARD INIT... SUCCESS", $00
Format          .text "N:C256JR,S", $00, "A"
HEX             .text "0123456789", $01, $02, $03, $04, $05, $00
* = $FE00
IRQ	
                LDA INT_PENDING_REG0
                CMP #$00
                BEQ CHECK_PENDING_REG1

                ; Process SOL
                LDA INT_PENDING_REG0
                AND #JR0_INT01_SOL
                CMP #JR0_INT01_SOL
                BNE CHECK_PENDING_REG1
                ; clear pending
                STA INT_PENDING_REG0

                
                lda BORDER_COLOR_R
                adc #$01
                sta BORDER_COLOR_R

                ; Process KBD
                LDA INT_PENDING_REG0
                AND #JR0_INT02_KBD
                CMP #JR0_INT02_KBD
                BNE CHECK_PENDING_REG1
                ; clear pending
                STA INT_PENDING_REG0

                LDA KBD_INPT_BUF      ; Get Scan Code from KeyBoard
                STA KEYBOARD_SC_TMP     ; Save Code Immediately


                bra CHECK_PENDING_REG1




CHECK_PENDING_REG1
                LDA INT_PENDING_REG1
                CMP #$00
                BEQ EXIT_IRQ_HANDLE          


EXIT_IRQ_HANDLE
				RTI 
* = $FF00
NMI	
				RTI 				

;
; Interrupt Vectors
;
* = $FFFA

RVECTOR_NMI     .addr NMI     ; FFEA
RVECTOR_RST 	.addr IBOOT    ; FFEC
RVECTOR_IRQ     .addr IRQ    ; FFEE
		
;                ldx #$00
;                ;IEC Test 
;                ; Send the command                
;                lda #$28
;                sta TALKER_CMD
;                lda #$F0 
;                sta TALKER_CMD
;                lda #$24 
;                sta TALKER_DTA_LAST
;                lda #$3F
;                sta TALKER_CMD_LAST
;                ; go read the data 
;                lda #$48
;                sta TALKER_CMD
;                lda #$60
;                sta TALKER_CMD
;waiting4lastdata:
;                lda LISTNER_FIFO_STAT
;                and #$80
;                cmp #$80
;                bne waiting4lastdata;;

;                lda #$5F
;                sta TALKER_CMD_LAST

                ; Close the transaction
;                lda #$28
                ;sta TALKER_CMD
;                lda #$E0 
;                sta TALKER_CMD
;                lda #$3F
;                sta TALKER_CMD_LAST
                 

                ;lda #$28
                ;sta TALKER_CMD
                ;lda #$FF
                ;sta TALKER_CMD
;NotDoneSending:
                ;lda Format, x
                ;cmp #$00
                ;beq Done_Sending 
                ;sta TALKER_DTA
                ;inx 
                ;bne NotDoneSending
;Done_Sending:   inx 
                ;lda Format, x
                ;sta TALKER_DTA_LAST
                ;lda #$3F
                ;sta TALKER_CMD_LAST
                
                
                
                
                
                ;
                ;lda #$48
                ;sta TALKER_CMD
                ;lda #$60
                ;sta TALKER_CMD       