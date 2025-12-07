; Executable name  : hexdump3 
; Version          : 3.0
; Created At       : 2025-12-04
; Author           : Guts thakur
; Description      : A simple hexdump utility function that will
;                    show how to use assembly procedures

SECTION .bss
SECTION .data
SECTION .text

%INCLUDE "textlib.asm"

GLOBAL _start

_start:
    mov rbp, rsp

; Whatever initialization needs doing before loop scan starts is here:
    xor r15, r15 ; Zero out r15, rsi, and rcx
    xor rsi, rsi
    xor rcx, rcx
    call LoadBuff ; Read first buffer of data from stdin
    cmp r15, 0 ; If r15 = 0, sys_read reached EOF on stdin
    jbe Exit

; Go through the buffer and convert binary byte values to hex digits:
Scan:
    xor rax, rax ; Clear RAX to 0
    mov al, [Buff+rcx] ; Get a byte from the buffer into AL
    mov rdx, rsi ; Copy total counter into RDX
    and rdx, 000000000000000Fh ; Mask out lowest 4 bits of char counter
    call DumpChar ; Call the char poke procedure

; Bump the buffer pointer to the next char and see if buffer's done:
    inc rsi ; Increment total chars processed counter
    inc rcx ; Increment buffer pointer
    cmp rcx, r15 ; Compare with # of chars in buffer
    jb .modTest ; If we've processed all chars in buffer...
    call LoadBuff ; ... go fill the buffer again
    cmp r15, 0 ; if r15 = 0, sys_read reached EOF on stdin
    jbe Done ; If we got EOF, we're done

; See if we're at the end of a block of 16 and need to display a line:
.modTest:
    test rsi, 000000000000000Fh ; Test 4 lowest bits in counter for 0
    jnz Scan ; If counter is *not* modulo 16, loop back
    call PrintLine ; ...otherwise print the line
    call ClearLine ; Clear hex dump line to 0's
    jmp Scan ; Continue scanning the buffer

; All done! Let's end this party:
Done: 
    call PrintLine ; Print the final "leftovers" line
Exit:
    mov rsp, rbp
    pop rbp
    
    ; Exit the program
    mov rax, 60 ; Specify sys_exit call
    mov rdi, 0  ; Specify sys_exit return code
    syscall
