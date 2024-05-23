#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------
.global main
;============================================================
; R16 --> register used to output to LCD
main:
;------------------------------------------------------------
    LDI   R17, 0b11111100 ;LDI 0b100 to R17
    OUT   DDRD, R17       ;set PD2 for o/p
    ;------------------------------------------------------
    LDI   R17, 0xFF       ;LDI 0b100 to R17
    OUT   DDRB, R17       ;set PORTB for o/p
    CBI   PORTB, 0        ;EN = 0
    RCALL delay_ms        ;wait for LCD power on
    ;------------------------------------------------------
    LDI   R17, (1<<SPE)   ;SET SPE flag to 1
    OUT   SPCR, R17       ;enable SPI as slave
    ;--------------------------------------------------
    RCALL LCD_init      ;subroutine to initialize LCD
    ;--------------------------------------------------
    ;RCALL disp_msg      ;display message on 1st line
    ;--------------------------------------------------
    LDI   R16, 0xC0     ;cursor beginning of 2nd line
    RCALL command_wrt
    RCALL delay_ms
    ;--------------------------------------------------
    LDI   R23, 48       ;constants used to get ASCII values
    LDI   R24, 7        ;for chars 0-->9 & A-->F
;============================================================
agn:  IN    R18, SPSR       ;store SPSR flag in R18
      SBRS  R18, SPIF       ;wait for byte reception
      RJMP  agn             ;to complete
      ;------------------------------------------------------
      IN    R18, SPDR       ;i/p byte from data register
      ;------------------------------------------------------
      CPI R18, 0x1E     ;compare immediate 1 on R18
      BRLO LED0         ;branch if lower to LED0
      CPI R18, 0x1F     ;compare immediate 2 on R18
      BRGE LED1         ;branch if lower to LED1
;===============================================================
LED0:
  LDI R19, 0b00000000 ;turn off LED on PD2
  OUT PORTD, R19      ;output R19 on PORTD
  RJMP continue       ;relative jump to continue
;------------------------------------------------------------------
LED1:
  LDI R19, 0b00001100 ;turn on LED on PD2
  OUT PORTD, R19      ;output R19 on PORTD
  RJMP continue       ;relative jump to continue
;------------------------------------------------------------------
continue:
    
    RJMP  agn      ;go back & get another ADC reading
;====================================================================


;===============================================================
LCD_init:
    LDI   R16, 0x33     ;init LCD for 4-bit data
    RCALL command_wrt   ;send to command register
    RCALL delay_ms
    LDI   R16, 0x32     ;init LCD for 4-bit data
    RCALL command_wrt
    RCALL delay_ms
    LDI   R16, 0x28     ;LCD 2 lines, 5x7 matrix
    RCALL command_wrt
    RCALL delay_ms
    LDI   R16, 0x0C     ;disp ON, cursor OFF
    RCALL command_wrt
    LDI   R16, 0x01     ;clear LCD
    RCALL command_wrt
    RCALL delay_ms
    LDI   R16, 0x06     ;shift cursor right
    RCALL command_wrt
    RET
;====================================================================
command_wrt:
    MOV   R27, R16
    ANDI  R27, 0xF0     ;mask low nibble & keep high nibble
    OUT   PORTD, R27    ;o/p high nibble to port D
    CBI   PORTB, 1      ;RS = 0 for command
    SBI   PORTB, 0      ;EN = 1
    RCALL delay_short   ;widen EN pulse
    CBI   PORTB, 0      ;EN = 0 for H-to-L pulse
    RCALL delay_us      ;delay 100us
    ;-------------------------------------------------------
    MOV   R27, R16
    SWAP  R27           ;swap nibbles
    ANDI  R27, 0xF0     ;mask low nibble & keep high nibble
    OUT   PORTD, R27    ;o/p high nibble to port D
    SBI   PORTB, 0      ;EN = 1
    RCALL delay_short   ;widen EN pulse
    CBI   PORTB, 0      ;EN = 0 for H-to-L pulse
    RCALL delay_us      ;delay 100us
    RET
data_wrt:
    MOV   R27, R16
    ANDI  R27, 0xF0     ;mask low nibble & keep high nibble
    OUT   PORTD, R27    ;o/p high nibble to port D
    SBI   PORTB, 1      ;RS = 1 for data
    SBI   PORTB, 0      ;EN = 1
    RCALL delay_short   ;make wide EN pulse
    CBI   PORTB, 0      ;EN = 0 for H-to-L pulse
    RCALL delay_us      ;delay 100us
    ;-------------------------------------------------------
    MOV   R27, R16
    SWAP  R27           ;swap nibbles
    ANDI  R27, 0xF0     ;mask low nibble & keep high nibble
    OUT   PORTD, R27    ;o/p high nibble to port D
    SBI   PORTB, 0      ;EN = 1
    RCALL delay_short   ;widen EN pulse
    CBI   PORTB, 0      ;EN = 0 for H-to-L pulse
    RCALL delay_us      ;delay in micro seconds
    RET
;====================================================================
delay_short:            ;very short delay, 3 cycles
    NOP
    NOP
    RET
;--------------------------------------------------
delay_us:               ;delay approximately 100us
    LDI   R20, 90
l3: RCALL delay_short
    DEC   R20
    BRNE  l3
    RET
;--------------------------------------------------
delay_ms:               ;delay approximately 20ms
    LDI   R21, 40
l4: RCALL delay_us
    DEC   R21
    BRNE  l4
    RET
;----------------------------------------------------------------
delay_seconds:          ;nested loop subroutine (max delay 3.11s)
    LDI   R20, 255      ;outer loop counter 
l5: LDI   R21, 255      ;mid loop counter
l6: LDI   R22, 20       ;inner loop counter to give 0.25s delay
l7: DEC   R22           ;decrement inner loop
    BRNE  l7            ;loop if not zero
    DEC   R21           ;decrement mid loop
    BRNE  l6            ;loop if not zero
    DEC   R20           ;decrement outer loop
    BRNE  l5            ;loop if not zero
    RET                 ;return to caller

