;;; Muistiinpanot ;;;
; Alkuosoitteet datalehden sivu 64
; PORTA   0x0400
; TCA0    0x0A00
; TCB0    0x0A80
; CPU     0x0030

; ldi = Load Immediate
; Arvon lataaminen prosessorin rekisteriin r0-r31

; in = In From I/O Location
; Vain osoitteet 0x00 - 0x3F
; 1 kellojakso

; lds = Load Direct from Data Space
; Koko data-muistiavaruus 0x0000 - 0xFFFF
; 2-3 kellojaksoa

; out = Out To I/O Location
; Vain osoitteet 0x00 - 0x3F

; sts = Store Direct to Data Space
; Arvon kirjoittaminen muistiosoitteeseen
; Toimii prosessorin rekisterien r16-r31 kanssa (ldi)

; rjmp = Relative Jump
; Ei tallenna paluuosoitetta

; rcall = aliohjelman kutsuminen
; Tallentaa paluuosoitteen (toimivaan) pinoon

; ret = Return
; Palaa aliohjelmasta rcall-käskyn jälkeiseen kohtaan

; reti = Return from Interrupt
; Paluu keskeytyspalvelurutiinista

; sbrs = Skip if Bit in Register is Set

; cpi = Compare with Immediate
;     breq = Branch if Equal
;     brne = Branch if Not Equal
;     brlo = Branch if Lower
;     brsh = Branch if Same or Higher

; .equ = equate
; symbolinen nimi jollekkin arvolle

; .org = origin
; Määrittää seuraavan koodin alkukohdan

; Ohjelmamuisti on 16-bittistä
; Datamuisti on 8-bittistä

;;; Vakioiden määritys ;;;
.equ CPU.SREG, 0x003F ; Status register (datalehti sivu 35)
.equ CPU_SPL,  0x003D ; s. 34
.equ CPU_SPH,  0x003E
.equ RAMEND,   0x3FFF

; PORTx rekisterit (s. 146)
.equ PORTA_DIR,      0x0400 ; Koko rekisterin suunnan asettaminen 0/1
.equ PORTA_DIRSET,   0x0401 ; Yksittäisen pinnin asettaminen lähdöksi
.equ PORTA_DIRCLR,   0x0402 ; Yksittäisen pinnin asettaminen tuloksi
.equ PORTA_OUT,      0x0404 ; Koko rekisterin lähtöjen asettaminen 0/1
.equ PORTA_OUTSET,   0x0405 ; Yksittäisen pinnin lähdön asettaminen 1
.equ PORTA_OUTCLR,   0x0406 ; Yksittäisen pinnin lähdön asettaminen 0
.equ PORTA_OUTTGL,   0x0407 ; Yksittäisen pinnin lähdön toggleeminen
.equ PORTA_IN,       0x0408 ; Pinnien fyysinen tila (Input Value)
.equ PORTA_INTFLAGS, 0x0409 ; Interrupt flags
; PINCTRL offset = 0x10 + n*0x01 [n=0..7]
.equ PORTA_PIN6CTRL, 0x0416 ; Pin n Control -rekisteri (sivu 158)

; TCA0-ajastimen rekisterit (s. 197, pääsivu s. 185)
.equ TCA0_CTRLA,     0x0A00
.equ TCA0_INTCTRL,   0x0A0A
.equ TCA0_INTFLAGS,  0x0A0B
.equ TCA0_PER,       0x0A26 ; 16-bittinen. High-byte = + 0x01

; TCB0-ajastimen rekisterit (s. 243, pääsivu s. 233)
.equ TCB0_CTRLA,     0x0A80
.equ TCB0_CTRLB,     0x0A81
.equ TCB0_INTCTRL,   0x0A85
.equ TCB0_INTFLAGS,  0x0A86
.equ TCB0_CNT,       0x0A8A ; 16-bittinen laskuri (L = 0x0A8A, H = 0x0A8B)
.equ TCB0_CCMP,      0x0A8C ; 16-bittinen vertailuarvo (L = 0x0A8C, H = 0x0A8D)

.equ CPU_SPL, 0x003D
.equ CPU_SPH, 0x003E
.equ RAMEND,  0x3FFF

; .global _stack
; .equ _stack, 0x3FFF

.section .vectors,"ax",@progbits
.global __vectors

__vectors: ; Datalehti s. 66
    .org 0x0000
    jmp RESET

    ; PORTA-pinneillä on vain yksi keskeytysvektori, joten jos on monta ulkoista
    ; keskeytystä saman ryhmän pinneistä, pitää kyseessä olevan pinnin tarkistus
    ; tehdä keskeytyksen sisällä.
    .org 0x0018 ; (0x000C * 2 = 0x0018)
    jmp PORTA_ISR

    .org 0x001C ; (0x000E * 2 = 0x001C)
    jmp TCA0_OVF_ISR

    ;.org 0x0030 ; 0x18 * 2 = 0x0030
    ;jmp TCB0_ISR

;;; Varsinainen ohjelma ;;;
.section .text
; .global main
; .global _main
; .type main, @function
; .type _main, @function

RESET:
; main:
; _main:
    ; Pino-osoitin
    ldi r16, lo8(RAMEND)
    out CPU_SPL, r16
    ldi r16, hi8(RAMEND)
    out CPU_SPH, r16

    ;PA7 lähdöksi (Nappi-ledi)
    ldi r16, (1 << 7)
    sts PORTA_DIRSET, r16
    sts PORTA_OUTSET, r16

    ;PA6 tuloksi (Nappi)
    ldi r16, (1 << 6) 
    sts PORTA_DIRCLR, r16
    ; Sisäinen pull-up ja keskeytys laskevalle reunalle
    ldi r16, 0b00001011
    sts PORTA_PIN6CTRL, r16

    ; Tyhjennä PA6:n vanha keskeytysflag
    ldi r16, (1 << 6)
    sts PORTA_INTFLAGS, r16

    ;PA5 lähdöksi (Karvalakkivilkku)
    ldi r16, (1 << 5)
    sts PORTA_DIRSET, r16
    sts PORTA_OUTSET, r16

    ;PA4 lähdöksi (TCA0-Ledivilkku)
    ldi r16, (1 << 4)
    sts PORTA_DIRSET, r16

    ; TCA0 jakso: 6510 tikkiä @ (3,33 MHz / 256 (prescaler alla)) = ~0,5 s
    ldi r16, lo8(6510)
    sts TCA0_PER, r16
    ldi r16, hi8(6510)
    sts TCA0_PER + 1, r16

    ; TCA0 ylivuotokeskeytys
    ldi r16, (1 << 0)
    sts TCA0_INTCTRL, r16

    ; Käynnistetään TCA0 (DIV256 = 0x0C + ENABLE = 1 -> 0x0D)
    ldi r16, 0x0D
    sts TCA0_CTRLA, r16

    ; Global Interrupt Enable
    sei

MAIN_LOOP:
    ; Vaihdetaan ledin tila
    ldi r16, (1 << 5)
    sts PORTA_OUTTGL, r16

    ; Viivesilmukka (~0,5 sekuntia oletuskellolla 3,33 MHz)
    ldi r18, 10             ; Ulompi laskuri
DELAY_1:
    ldi r19, 255            ; Keskimmäinen laskuri
DELAY_2:
    ldi r20, 255            ; Sisempi laskuri
DELAY_3:
    dec r20                 ; Vähennä r20 yhdellä (1 kellojakso)
    brne DELAY_3            ; Hyppää takaisin, jos r20 != 0 (2 kellojaksoa)
    dec r19
    brne DELAY_2
    dec r18
    brne DELAY_1

    ; Koko viiveen kesto noin 10 * 255 * 255 * 3 = 1950750 kellojaksoa
    ; Vakiokellolla 3,333 MHz se vastaa noin 0,58 s.

    rjmp MAIN_LOOP

; PA6 keskeytys
PORTA_ISR:
    ; Tallennetaan r16 pinoon, että keskeytys ei muuta pääohjelman toimintaa
    push r16
    in r16, CPU.SREG ; Tallennetaan CPU.SREG pinoon
    push r16

    ; Ledin togglaaminen
    ldi r16, (1 << 7)
    sts PORTA_OUTTGL, r16

    ; Keskeytyslipun tyhjennys PA6
    ldi r16, (1 << 6)
    sts PORTA_INTFLAGS, r16

    pop r16 ; Palauta SREG
    out CPU.SREG, r16
    pop r16 ; Palautetaan r16 arvo
    reti

; Keskeytysrutiini (ajetaan 0,5 s välein)
TCA0_OVF_ISR:
    push r16
    in r16, CPU.SREG
    push r16

    ; 1. Tyhjennetään TCA0 OVF-lippu
    ldi r16, (1 << 0)
    sts TCA0_INTFLAGS, r16

    ; 2. Vaihdetaan ledin tila PA4
    ldi r16, (1 << 4)
    sts PORTA_OUTTGL, r16

    pop r16
    out CPU.SREG, r16
    pop r16
    reti
