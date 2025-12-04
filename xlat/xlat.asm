; Executable Name: xlat
; Version: 1.0
; Created At: 2025-12-04
; Author: Guts
; Description: A simple program to uppercase the english letter,
;              demonstrating the use of lookup table and xlat instruction
;              set

section .bss                 ; Uninitialized variables
    READLEN equ 1024         ; Length of Buffer
    ReadBuffer: resb READLEN ; Text buffer itself

section .data                ; Initialized variables
    StatMsg: db "Processing...", 10
    StatLen: equ $-StatMsg
    DoneMsg: db "...Done!", 10 
    DoneLen: equ $-DoneMsg
; The following translation table translates all lowercase characters 
; to uppercase. It also translates all non-printable characters to space, except for LT and HT. This is the table used by default
; in the program
    UpCase:
        db 20h,20h,20h,20h,20h,20h,20h,20h,20h,09h,0Ah,20h,20h,20h,20h,20h ;   0- 15
        db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h ;  16- 31
        db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh ;  32- 47
        db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh ;  48- 63
        db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh ;  64- 79
        db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh ;  80- 95
        db 60h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh;  96-111
        db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,7Bh,7Ch,7Dh,7Eh,20h ; 112-127
        db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h ; 128-143
        db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h ; 144-159
        db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h ; 160-175
        db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h ; 176-191
        db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h ; 192-207
        db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h ; 208-223
        db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h ; 224-239
        db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h ; 240-255

section .text
    global _start

_start:
    mov rbp, rsp
    ; Display i'm working message
    mov rax, 1 ; sys_call write 1
    mov rdi, 1 ; file descriptor 1, stdout
    mov rsi, StatMsg ; Message to print
    mov rdx, StatLen ; Length of the message to print
    syscall ; invoke syscall

; Read a buffer full of text from the stdin
read:
    mov rax, 0 ; sys_call read 0
    mov rdi, 0 ; file descriptor 0, stdin
    mov rsi, ReadBuffer ; to read the data into
    mov rdx, READLEN ; length of text to read
    syscall ; invoke syscall
    mov rbp, rax ; copy sys_read read value for safekeeping
    cmp rax, 0 ; if reached EOF, jump to done
    je done ; jump if equal (i.e. rax = 0)

    mov rbx, UpCase ; put the address of the translation table in rbx
    mov rdx, ReadBuffer ; put the address of read buffer in rdx
    mov rcx, rbp ; place number of bytes read in buffer to rcx

; Translate the value in buffer via UpCase Table
translate:
    xor rax, rax ; Clear the rax value
    mov al, byte [rdx-1+rcx] ; Load character into AL for translation
    xlat ; translate character in al via table
    mov byte [rdx-1+rcx], al ; Move 
    dec rcx ; decrement character count
    jnz translate ; if there are more characters in buffer, repeat

; Write the output to the stdout
write:
    mov rax, 1 ; sys_call write 1
    mov rdi, 1 ; file descriptor 1, stdout
    mov rsi, ReadBuffer ; Data to write
    mov rdx, READLEN ; lenght to data to write
    syscall ; invoke syscall
    jmp read ; again read from the stdin

; Write I'm done message
done:
    mov rax, 1 ; sys_call write 1
    mov rdi, 1 ; file descriptor 1, stdout
    mov rsi, DoneMsg ; Msg to print
    mov rdx, DoneLen ; length of the msg to print
    syscall ; invoke syscall

ret:
    ; All done exit the code
    mov rax, 60 ; syscall exit
    mov rdi, 0  ; return code
    syscall
