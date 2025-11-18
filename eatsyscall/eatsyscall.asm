; Executable name: EATSYSCALL
; Version: 1.0
; Created date: 2025-11-16
; Author: Guts
; Description: A simple program in assembly for Linux, using NASM

; Build using the following command
; nasm -f elf64 -g -F dwarf eatsyscall.asm
; ld -o eatsyscall eatsyscall.o

SECTION .data                  ; Section containing intialized data

    EatMsg: db "Bankai", 0Ah
    EatLen: equ $-EatMsg

SECTION .bss                   ; Section containing uninitialized data

SECTION .text                  ; Section containing code

global _start                  ; Linked need this to find the starting point

_start:
    mov rbp, rsp                   ; for correct debugging
    nop                            ; This no-op for gdb

    mov rax, 1                     ; Specify sys_write call
    mov rdi, 1                     ; Specify fd = 1, standard output
    mov rsi, EatMsg                ; Pass offset of the message
    mov rdx, EatLen                ; Pass the length of the message
    syscall                        ; Make kernal call

    mov rax, 60                    ; Specify the sys_exit call
    mov rdi, 0                     ; Return status code
    syscall                        ; Make kernal call
