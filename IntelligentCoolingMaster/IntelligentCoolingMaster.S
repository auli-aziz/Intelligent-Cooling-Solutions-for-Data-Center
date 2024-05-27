#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------
.global main
;==============================================================
main:
;---------------------------
;SPI port number declaration
;---------------------------
.equ  SCK, 5
.equ  MOSI, 3
.equ  SS, 2
;--------------------------------------------------------------
      LDI   R17, (1<<MOSI)|(1<<SCK)|(1<<SS) ;set MOSI, SCK, SS as o/p
      OUT   DDRB, R17       ;store value of R17 in DDRB
      ;--------------------------------------------------------
      LDI   R17, (1<<SPE)|(1<<MSTR)|(1<<SPI2X)|(1<<SPR0)
      OUT   SPCR, R17       ;enable SPI as master, fsck=fosc/8, SPI mode 0
      ;--------------------------------------------------------
      LDI   R17, 0xFF       ;LDI 0b11111111 to R17
      OUT   DDRD, R17       ;set PORTD for o/p (LED control)
      ;--------------------------------------------------------
;=================================================================
agn: RCALL delay_2s      ;wait 2s for DHT11 to get ready
;=================================================================
;start_signal
;------------
    SBI   DDRC, 0       ;pin A0 as o/p --
    CBI   PORTC, 0      ;first, send low pulse
    RCALL delay_20ms    ;for 20ms
    SBI   PORTC, 0      ;then send high pulse
;-----------------------------------------------------------------
;response signal
;---------------
    CBI   DDRC, 0       ;pin A0 as i/p --
w1: SBIC  PINC, 0       ;skip next jmp if A0 0 --
    RJMP  w1            ;wait for DHT11 low pulse
w2: SBIS  PINC, 0       ;skip next jmp if A0 1 --
    RJMP  w2            ;wait for DHT11 high pulse
w3: SBIC  PINC, 0       ;skip next jmp if A0 0 --
    RJMP  w3            ;wait for DHT11 low pulse
;-----------------------------------------------------------------
    RCALL DHT11_reading ;read humidity (1st byte ignored)
    RCALL DHT11_reading ;read humidity (2nd byte ignored)
    RCALL DHT11_reading ;read temperature (3rd byte of 40-bit data)
;==============================================================
send: CBI   PORTB, SS       ;enable slave device
      OUT   SPDR, R18       ;transmit byte to slave
      ;--------------------------------------------------------
loop: IN    R19, SPSR       ;store the value of SPSR in R19
      SBRS  R19, SPIF       ;wait for byte transmission
      RJMP  loop            ;to complete
      ;--------------------------------------------------------
      SBI   PORTB, SS       ;disable slave device
      ;--------------------------------------------------------
      ; Control LED based on received temperature data
      CPI   R18, 20         ;compare received temperature with 20
      BRLO  LED_COLD        ;branch if lower to LED_COLD
      CPI   R18, 30         ;compare received temperature with 30
      BRLO  LED_NORMAL      ;branch if lower to LED_NORMAL
      ;--------------------------------------------------------
LED_HOT:
      LDI   R16, 1
      CBI   PORTD, 0        ;turn off LED on PD0
      CBI   PORTD, 1        ;turn off LED on PD1
      SBI   PORTD, 2        ;turn on LED on PD2 (hot condition)
      SBI   PORTD, 3        ;turn on Fan on PD3
      RJMP  CONTINUE
      ;--------------------------------------------------------
LED_NORMAL:
      LDI   R16, 2
      CBI   PORTD, 0        ;turn off LED on PD0
      SBI   PORTD, 1        ;turn on LED on PD1 (normal condition)
      CBI   PORTD, 2        ;turn off LED on PD2
      CBI   PORTD, 3        ;turn off Fan on PD3
      RJMP  CONTINUE
      ;--------------------------------------------------------
LED_COLD:
      LDI   R16, 3
      SBI   PORTD, 0        ;turn on LED on PD0 (cold condition)
      CBI   PORTD, 1        ;turn off LED on PD1
      CBI   PORTD, 2        ;turn off LED on PD2
      CBI   PORTD, 3        ;turn off Fan on PD3
      RJMP  CONTINUE
      ;--------------------------------------------------------
CONTINUE:
      CPI   R16, 1
      BREQ  blink
cont: RCALL delay_2s        ;delay
      RJMP  agn             ;repeat transmission
;=================================================================
blink:
      SBI   PORTD, 2
      RCALL delay_timer1
      CBI   PORTD, 2
      RCALL delay_timer1
      SBI   PORTD, 2
      RCALL delay_timer1
      CBI   PORTD, 2
      RCALL delay_timer1
      SBI   PORTD, 2
      RCALL delay_timer1
      CBI   PORTD, 2
      RCALL delay_timer1
      SBI   PORTD, 2
      RCALL delay_timer1
      CBI   PORTD, 2
      RCALL delay_timer1
      SBI   PORTD, 2
      RCALL delay_timer1
      CBI   PORTD, 2
      RCALL delay_timer1
      SBI   PORTD, 2
      MOV   R16, 0
      RJMP  cont
;=================================================================
delay_20ms:             ;delay 20ms
    LDI   R21, 255      ;LDI 255 into R21
l3: LDI   R22, 210      ;LDI 210 into R22
l4: LDI   R23, 2        ;LDI 2 into R23
l5: DEC   R23           ;Decrement R23
    BRNE  l5            ;Branch if not equal to zero to label l5
    DEC   R22           ;Decrement R22
    BRNE  l4            ;Branch if not equal to zero to label l4
    DEC   R21           ;Decrement R21
    BRNE  l3            ;Branch if not equal to zero to label l3
    RET                 ;Return from subroutine
;-----------------------------------------------------------------
delay_2s:               ;delay 2s
    LDI   R21, 255      ;LDI 255 into R21
l6: LDI   R22, 255      ;LDI 255 into R22
l7: LDI   R23, 164      ;LDI 164 into R23
l8: DEC   R23           ;Decrement R23
    BRNE  l8            ;Branch if not equal to zero to label l8
    DEC   R22           ;Decrement R22
    BRNE  l7            ;Branch if not equal to zero to label l7
    DEC   R21           ;Decrement R21
    BRNE  l6            ;Branch if not equal to zero to label l6
    RET                 ;Return from subroutine
;-----------------------------------------------------------------
delay_timer0:             ;50 usec delay via Timer 0
    ;---------------------------------------------------------
    CLR   R20             ;Clear R20
    OUT   TCNT0, R20      ;initialize timer0 with count=0
    LDI   R20, 100        ;LDI 100 to R20
    OUT   OCR0A, R20      ;OCR0 = 100
    LDI   R20, 0b00001010 ;LDI 10101 to R20
    OUT   TCCR0B, R20     ;timer0: CTC mode, prescaler 8
    ;---------------------------------------------------------
l2: IN    R20, TIFR0      ;get TIFR0 byte & check
    SBRS  R20, OCF0A      ;if OCF0=1, skip next instruction
    RJMP  l2              ;else, loop back & check OCF0 flag
    ;---------------------------------------------------------
    CLR   R20             ;Clear R20
    OUT   TCCR0B, R20     ;stop timer0
    ;---------------------------------------------------------
    LDI   R20, (1<<OCF0A) ;LDI (1 shifted left by OCF0A) into register R20
    OUT   TIFR0, R20      ;clear OCF0 flag
    RET                   ;return to terminal call
;-----------------------------------------------------------------
delay_timer1:             ;0.35 sec delay via timer1
    ;-------------------------------------------------------
.EQU value, 60067         ;value to give 0.35 sec delay
    LDI   R20, hi8(value) ;load high byte of value into R20
    STS   TCNT1H, R20     ;store R20 value into high byte of TCNT1
    LDI   R20, lo8(value) ;load low byte of value into R20
    STS   TCNT1L, R20     ;initialize counter TCNT1 = value
    ;-------------------------------------------------------
    LDI   R20, 0b00000000 ;configure TCCR1A for normal operation
    STS   TCCR1A, R20     ;store R20 value into TCCR1A
    LDI   R20, 0b00000101 ;configure TCCR1B for prescaler of 1024
    STS   TCCR1B, R20     ;normal mode, prescaler = 1024
    ;-------------------------------------------------------
l9: IN    R20, TIFR1      ;get TIFR1 byte & check
    SBRS  R20, TOV1       ;if TOV1=1, skip next instruction
    RJMP  l9              ;else, loop back & check TOV1 flag
    ;-------------------------------------------------------
    LDI   R20, 1<<TOV1    ;set TOV1 flag in TIFR1 register 
    OUT   TIFR1, R20      ;clear TOV1 flag
    ;-------------------------------------------------------
    LDI   R20, 0b00000000 ;stop Timer/Counter1
    STS   TCCR1B, R20     ;store R20 value into TCCR1B
    RET                   ;return from subroutine
;===============================================================
DHT11_reading:          
    LDI   R17, 8        ;set counter for receiving 8 bits
    CLR   R18           ;clear data register
    ;-------------------------------------------------------
w4: SBIS  PINC, 0       ;skip jmp if A0 is 1 --
    RJMP  w4            ;detect data bit (high pulse)
    RCALL delay_timer0  ;wait 50us & then check bit value
    ;-------------------------------------------------------
    SBIS  PINC, 0       ;if received bit=1, skip next inst
    RJMP  skp           ;else, received bit=0, jump to skp
    SEC                 ;set carry flag (C=1)
    ROL   R18           ;shift in 1 into LSB data register
    RJMP  w5            ;jump & wait for next bit
skp: CLC                 ;clear carry flag (C=0)
    ROL   R18           ;shift in 0 into LSB data register
w5: SBIC  PINC, 0       ;skip jmp if A0 0 --
    RJMP  w5            ;wait for end of data bit pulse
    DEC   R17           ;decrement bit counter
    BRNE  w4            ;repeat till all bits received
    RET                 ;return to caller
