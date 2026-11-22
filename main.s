;;; Muistiinpanot ;;;
; PORTA alkuosoite 0x0400

; ldi = Load Immediate
; Arvon lataaminen prosessorin rekisteriin r0-r31

; sts = Store Direct to Data Space
; Arvon kirjoittaminen muistiosoitteeseen
; Toimii prosessorin rekisterien r16-r31 kanssa (ldi)

; rjmp = Relative Jump
; Ei tallenna paluuosoitetta

; rcall = aliohjelman kutsuminen
; Tallentaa paluuosoitteen (toimivaan) pinoon

; ret = palaa aliohjelmasta rcall-käskyn jälkeiseen kohtaan

;;; Vakioiden määritys ;;;
.equ PORTA_DIR,    0x0400 ; Koko rekisterin suunnan asettaminen 0/1
.equ PORTA_DIRSET, 0x0401 ; Yksittäisen pinnin asettaminen lähdöksi
.equ PORTA_DIRCLR, 0x0402 ; Yksittäisen pinnin asettaminen tuloksi
.equ PORTA_OUT,    0x0404 ; Koko rekisterin lähtöjen asettaminen 0/1
.equ PORTA_OUTSET, 0x0405 ; Yksittäisen pinnin lähdön asettaminen 1
.equ PORTA_OUTCLR, 0x0406 ; Yksittäisen pinnin lähdön asettaminen 0
.equ PORTA_OUTTGL, 0x0407 ; Yksittäisen pinnin lähdön toggleeminen

.section .text
.global __vectors

__vectors:
    rjmp RESET

RESET:
    ;PA7 lähdöksi
    ldi r16, (1 << 7) 
    sts PORTA_DIRSET, r16
    sts PORTA_OUTSET, r16


MAIN_LOOP:
    nop

    rjmp MAIN_LOOP
