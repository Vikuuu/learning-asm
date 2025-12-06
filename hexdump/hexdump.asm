; Executable Name: hexdump
; Version: 1.0
; Created data: 2025-11-30
; Author: Guts Thakur
; Description: A simple program in assembly for Linux, demonstrating the 
;              conversion of binary values to hexadecimal strings
;              It acts as a very simple hex dump utility for files,
;              without the ASCII equivalent column.

; Run it this way:
;  hexdump < (input_file)
;
SECTION .bss              ; Section containing uninitialized data

    BUFFLEN equ 16        ; We read the file 16 bytes at a time
    Buff:   resb BUFFLEN  ; Text buffer itself, reserve 16 byte

SECTION .data       ; Section containing initialised data

    HexStr: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00", 10
    HEXLEN equ $-HexStr

    Digits: db "0123456789ABCDEF"

SECTION .text ; Section containing code
    global _start ; Linked needs this to find the starting point


_start:
    mov rbp, rsp

; Read a buffer full of text from stdin
Read:
    mov rax, 0       ; Specify sys_read call 0
    mov rdi, 0       ; Specify file descripter 0: stdin
    mov rsi, Buff    ; Pass offset to the buffer to read to
    mov rdx, BUFFLEN ; Pass number of bytes to read at one pass
    syscall
    mov r15, rax     ; Save # of bytes read from the file for later use
    cmp rax, 0       ; If rax = 0, EOF reached
    je Done          ; Jump if Equal (to 0, from compare)

; Set up the registers for the process buffer step:parm
    mov rsi, Buff   ; Place address of file buffer into esi
    mov rdi, HexStr ; Place address of line string inot edi
    xor rcx, rcx    ; Clear line string pointer to 0

; Go through the buffer and convert binary values to hex digits:
Scan:
    xor rax, rax  ; Clear rax to 0

; Here we calculate the offset into the line string, which is rcx X 3
    mov rdx, rcx  ; Copy the pointer into line string into rdx
;   shl rdx, 1    ; Multiply pointer by 2 using left shift
;   add rdx, rcx  ; Complete the multiplication X3
    lea rdx, [rdx*2+rdx] ; This does what the above 2 lines do!

; Get a character from the buffer and put it in both rax and rbx:
    mov al, byte [rsi+rcx] ; Put a byte from the input buffer into al
    mov rbx, rax           ; Duplicate byte in bl for second nybble

; Look up low nybble character and insert it inot the string:
    and al, 0Fh ; Mask out all but the low nybble
    mov al, byte [Digits+rax] ; Look up the char equivalent of nyble
    mov byte [HexStr+rdx+2], al ; Write the char equivalent to the line string

; Look up high nybble character and insert it into the string:
    shr bl, 4 ; Shift high 4 bits of char into low 4 bits
    mov bl, byte [Digits+rbx] ; Look up char equivalent of nybble
    mov byte [HexStr+rdx+1], bl; Write the char equivalent to the line string

; Bump the buffer pointer to the next character and see if we're done:
    inc rcx ; Increment line string pointer
    cmp rcx, r15 ; Compare to the number of characters in the buffer
    jna Scan ; Loop back if rcx is <= number of chars in buffer

; Write the line of hexadecimal values to stdout:
    mov rax, 1 ; Specify syscall 1, sys_write
    mov rdi, 1 ; Specify file description, 1 - stdout
    mov rsi, HexStr ; Pass address of line string is rsi
    mov rdx, HEXLEN ; Pass size of the line string in rdx
    syscall ; Make kernal call
    jmp Read ; Loop back and load file buffer again

; All done ! Let's end this party:
Done:
    mov rax, 60 ; Specify syscall 60, sys_exit
    mov rdi, 0  ; Return code 0, succes
    syscall     ; Call exit syscall
