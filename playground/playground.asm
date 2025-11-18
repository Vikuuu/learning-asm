section .data
    Snippet db "KANGAROO"
    SnippetLen equ $-Snippet

section .text
global _start

_start:
    mov rbp, rsp ; Save stack pointer
    nop

    xor rdx, rdx
    mov rax, 247
    mov rbx, 0
    div rbx

    ;   
    nop
    mov rax, 60 ; exit program syscall
    mov rbx, 0  ; return status call 
    syscall
