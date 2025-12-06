section .data

section .bss

section .text

;--------------------------------------------------------------------------------
; Newline procedure
;--------------------------------------------------------------------------------
newline:
    cmp rdx, 15
    ja .exit
    mov rsi, EOLs
    mov rax, 1
    mov rdi, 1 
    syscall
.exit:
    ret

EOLs db 10,10,10,10,10,10,10,10,10,10,10,10,10,10,10

global _start

_start:
    mov rdx, 15
    call newline

    mov rax, 60
    mov rdi, 0
    syscall
