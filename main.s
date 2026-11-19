;;; Muistiinpanot ;;;
; PORTA alkuosoite 0x0400

; ldi = Load Immediate
; Arvon lataaminen prosessorin rekisteriin r0-r31

; sts = Store Direct to Data Space
; Arvon kirjoittaminen muistiosoitteeseen
; Toimii prosessorin rekisterien r16-r31 kanssa (ldi)

;;; Vakioiden määritys ;;;
.equ PORTA_DIRSET, 0x0401
.equ PORTA_OUTSET, 0x0405
.equ PORTA_OUTCLR, 0x0406
.equ PORTA_OUTTGL, 0x0407

.section .text
.global __vectors

__vectors:
    rjmp RESET

RESET:
    ldi r16, 0b10000000
    sts PORTA_DIRSET, r16

MAIN_LOOP:
    rjmp MAIN_LOOP
