SECTION .data
                ;0000000000111
                ;0123456789012
    EditBuff db 'abcdefghijklm '
    BUFFLEN  equ $-EditBuff
    ENDPOS   equ 12 ; 0-based number of last variable character
    INSRTPOS equ 1

SECTION .text

global _start

_start:
    mov rbp, rsp ; for correct debugging
    nop

    std ; We're doing a "downhill" transfer
    mov rbx, EditBuff
    mov rsi, EditBuff+ENDPOS ; Start at end of visible text
    mov rdi, EditBuff+ENDPOS+1 ; Bump text right by 1
    mov rcx, ENDPOS-INSRTPOS+2 ; # of chars to bump; not a 0-based
                                ; address but a count
    rep movsb ; Move 'em!
    mov byte [rbx], ' ' ; Write a space at insert position

    nop
