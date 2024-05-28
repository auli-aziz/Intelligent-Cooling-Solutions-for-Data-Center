;-------------------------------------------------
; Intelligent Cooling Solutions for Data Centers
;-------------------------------------------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------
.global main
;============================================================
main:
;------------------------------------------------------------
    LDI   R17, 0xFF       ;LDI 0b11111111 to R17
    OUT   DDRD, R17       ;set PD for output
    OUT   DDRB, R17       ;set PORTB for output
    CBI   PORTB, 0        ;EN = 0
    RCALL delay_ms        ;wait for LCD power on
    ;------------------------------------------------------
    LDI   R17, (1<<SPE)   ;SET SPE flag to 1
    OUT   SPCR, R17       ;enable SPI as slave
    ;--------------------------------------------------
    RCALL LCD_init      ;subroutine to initialize LCD
    ;--------------------------------------------------
    RCALL disp_msg
    ;--------------------------------------------------
    LDI   R16, 0xC0     ;cursor beginning of 2nd line
    RCALL command_wrt
    RCALL delay_ms
    ;--------------------------------------------------
    LDI   R23, 48       ;constants used to get ASCII values
;============================================================
agn:  IN    R18, SPSR       ;store SPSR flag in R18
      SBRS  R18, SPIF       ;wait for byte reception
      RJMP  agn             ;to complete
      ;------------------------------------------------------
      IN    R18, SPDR       ;input byte from data register
      ;------------------------------------------------------
      CLR   R24           ;set counter1, initail value 0
      CLR   R25           ;set counter2, initail value 0
      ;------------------------------------------------------
      CPI   R18, 228
      BRPL  adjust
      ;------------------------------------------------------
l1:   CPI   R18, 100  
Ret:  BRMI  l2
      INC   R24
      SUBI  R18, 100
      RJMP  l1
      ;------------------------------------------------------
l2:   CPI   R18, 10
      BRMI  dsp
      INC   R25
      SUBI  R18, 10
      RJMP  l2
      ;------------------------------------------------------
dsp:  PUSH  R18
      ADD   R24, R23
      MOV   R18, R24
      MOV   R16, R18
      RCALL data_wrt
      ;------------------------------------------------------
      MOV   R18, R25
      ADD   R18, R23
      MOV   R16, R18
      RCALL data_wrt
      ;------------------------------------------------------
      POP   R18
      ADD   R18, R23
      MOV   R16, R18
      RCALL data_wrt
      ;------------------------------------------------------
      RCALL   delay_sec
      ;------------------------------------------------------
      LDI   R16, 0xC0     ;force cursor beginning of 2nd line
      RCALL command_wrt
      RCALL delay_ms
      ;------------------------------------------------------
      RJMP  agn      ;go back
;============================================================
adjust:
    CPI   R18, 128      ;compare R16 with 128 when R16 >= 228
    RJMP  Ret
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
      OUT   PORTD, R27    ;output high nibble to port D
      CBI   PORTB, 1      ;RS = 0 for command
      SBI   PORTB, 0      ;EN = 1
      RCALL delay_short   ;widen EN pulse
      CBI   PORTB, 0      ;EN = 0 for H-to-L pulse
      RCALL delay_us      ;delay 100us
    ;-------------------------------------------------------
      MOV   R27, R16
      SWAP  R27           ;swap nibbles
      ANDI  R27, 0xF0     ;mask low nibble & keep high nibble
      OUT   PORTD, R27    ;output high nibble to port D
      SBI   PORTB, 0      ;EN = 1
      RCALL delay_short   ;widen EN pulse
      CBI   PORTB, 0      ;EN = 0 for H-to-L pulse
      RCALL delay_us      ;delay 100us
      RET
;====================================================================
data_wrt:
      MOV   R27, R16
      ANDI  R27, 0xF0     ;mask low nibble & keep high nibble
      OUT   PORTD, R27    ;output high nibble to port D
      SBI   PORTB, 1      ;RS = 1 for data
      SBI   PORTB, 0      ;EN = 1
      RCALL delay_short   ;make wide EN pulse
      CBI   PORTB, 0      ;EN = 0 for H-to-L pulse
      RCALL delay_us      ;delay 100us
    ;-------------------------------------------------------
      MOV   R27, R16
      SWAP  R27           ;swap nibbles
      ANDI  R27, 0xF0     ;mask low nibble & keep high nibble
      OUT   PORTD, R27    ;output high nibble to port D
      SBI   PORTB, 0      ;EN = 1
      RCALL delay_short   ;widen EN pulse
      CBI   PORTB, 0      ;EN = 0 for H-to-L pulse
      RCALL delay_us      ;delay in microseconds
      RET
;====================================================================
disp_msg:
    LDI   R31, hi8(msg)
    LDI   R30, lo8(msg) ;Z points to string msg
l8: LPM   R16, Z+       ;load character of msg into R16
    CPI   R16, 0        ;check if R16=0 (end of string)
    BREQ  ext           ;if yes, exit
    RCALL data_wrt      ;if no, display character on LCD
    RJMP  l8            ;loop back & get next character
ext:RET
;--------------------------------------------------------------------
msg: .ascii "Current temp (C)"
;====================================================================
delay_short:            ;very short delay, 3 cycles
      NOP
      NOP
      RET
;--------------------------------------------------
delay_us:               ;delay approximately 100us
      LDI   R20, 90
l3:   RCALL delay_short
      DEC   R20
      BRNE  l3
      RET
;--------------------------------------------------
delay_ms:               ;delay approximately 20ms
      LDI   R21, 40
l4:   RCALL delay_us
      DEC   R21
      BRNE  l4
      RET
;----------------------------------------------------------------
delay_sec:                ;nested loop subroutine (max delay 3.11s)
      LDI   R20, 255      ;outer loop counter 
l5:   LDI   R21, 255      ;mid loop counter
l6:   LDI   R22, 20       ;inner loop counter to give 0.25s delay
l7:   DEC   R22           ;decrement inner loop
      BRNE  l7            ;loop if not zero
      DEC   R21           ;decrement mid loop
      BRNE  l6            ;loop if not zero
      DEC   R20           ;decrement outer loop
      BRNE  l5            ;loop if not zero
      RET                 ;return to caller
