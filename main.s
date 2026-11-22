;;; Muistiinpanot ;;;
; Alkuosoitteet datalehden sivu 64
; PORTA alkuosoite 0x0400
; CPU alkusosite 0x0030

; ldi = Load Immediate
; Arvon lataaminen prosessorin rekisteriin r0-r31

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

; .equ = equate
; symbolinen nimi jollekkin arvolle

; .org = origin
; Määrittää seuraavan koodin alkukohdan

; Ohjelmamuisti on 16-bittistä
; Datamuisti on 8-bittistä

;;; Vakioiden määritys ;;;
.equ CPU.SREG, 0x003F ; Status register (datalehti sivu 35)

.equ PORTA_DIR,      0x0400 ; Koko rekisterin suunnan asettaminen 0/1
.equ PORTA_DIRSET,   0x0401 ; Yksittäisen pinnin asettaminen lähdöksi
.equ PORTA_DIRCLR,   0x0402 ; Yksittäisen pinnin asettaminen tuloksi
.equ PORTA_OUT,      0x0404 ; Koko rekisterin lähtöjen asettaminen 0/1
.equ PORTA_OUTSET,   0x0405 ; Yksittäisen pinnin lähdön asettaminen 1
.equ PORTA_OUTCLR,   0x0406 ; Yksittäisen pinnin lähdön asettaminen 0
.equ PORTA_OUTTGL,   0x0407 ; Yksittäisen pinnin lähdön toggleeminen
.equ PORTA_INTFLAGS, 0x0409 ; Interrupt flags
; PINCTRL offset = 0x10 + n*0x01 [n=0..7]
.equ PORTA_PIN6CTRL, 0x0416 ; Pin n Control -rekisteri (sivu 158)

.section .vectors,"ax",@progbits
.global __vectors

__vectors:
    .org 0x0000
    jmp RESET

    ; PORTA-pinneillä on vain yksi keskeytysvektori, joten jos on monta ulkoista
    ; keskeytystä saman ryhmän pinneistä, pitää kyseessä olevan pinnin tarkistus
    ; tehdä keskeytyksen sisällä.
    .org 0x0018 ; (0x000C * 2 = 0x0018) datalehti sivu 66
    jmp PORTA_ISR

;;; Varsinainen ohjelma ;;;
.section .text

RESET:
    ;PA7 lähdöksi
    ldi r16, (1 << 7)
    sts PORTA_DIRSET, r16
    sts PORTA_OUTSET, r16

    ;PA6 tuloksi
    ldi r16, (1 << 6) 
    sts PORTA_DIRCLR, r16
    ; Sisäinen pull-up ja keskeytys laskevalle reunalle
    ldi r16, 0b00001011
    sts PORTA_PIN6CTRL, r16

    ; Tyhjennä PA6:n vanha keskeytysflag
    ldi r16, (1 << 6)
    sts PORTA_INTFLAGS, r16

    ; Global Interrupt Enable
    ;ldi r16, 0b10000000
    ;sts CPU.SREG, r16

    sei

MAIN_LOOP:
    nop

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
