; Executable name: uppercase
; Version: 1.0
; Created at: 2025-11-19
; Updated at: 
; Author: Guts
; Description: Convert any lowercase letter to uppercase


; Bound of the program
;  - Working in linux
;  - Data in disk
;  - Unknown data length
;  - We will use I/O redirection to pass the filename
;  - All input in same encoding
;  - We must preserve the original file

; Psuedocode
;     - Read a character from the file.
;     - Convert the character to uppercase(if necessary).
;     - Write character to the output file.
;     - Repeat until done

; Psuedocode refinement no. 1
; - Read a character from standard input.
; - Test the character to if lowercase?
; - If lowercase convert it to the uppercase, by subtracting 20h.
; - Write character to the standard output.
; - Repeat until done
; - Exit program by calling sys_exit.

; Psuedocode refinement no. 2
; - Read a character from standard input.
; - Test if we have reached the End of File?
;    - If we have, we are done jump to exit.
; - Test the character to if lowercase?
;    - If lowercase convert it to the uppercase, by subtracting 20h.
; - Write character to the standard output.
; - Go back and read another character
; - Exit program by calling sys_exit.

; Psuedocode refinement no. 2
; - Read: Set up register for sys_read call.
; - Call sys_read to read from stdin.
; - Test for EOF.
;    - If we're at EOF, jump to Exit.
; 
; - Test the character to see if it's lowercase.
; - If it's not lowercase, jump to Write.
; - Convert the character to uppercase by subracting 20h.
; 
; - Write: Set up register for sys_write call.
; - Call sys_write to write to stdout.
; - Jump back to Read and get another character.
; 
; - Exit: Set up register for terminating the program via sys_exit.
; - Call sys_exit.

SECTION .bss   ; Section containing unintialized data
    Buff resb 1

SECTION .data  ; Section containing intialized data

SECTION .text     ; Section containing code
    global _start ; Linker need this, to find the starting point

_start:
    mov rbp, rsp ; For correct debugging

    Read:
        mov rax, 0     ; Kernal call: sys_read
        mov rdi, 0     ; File descriptor = 0, stdin
        mov rsi, Buff  ; Pass buffer addr to read to
        mov rdx, 1     ; Read 1 character from stdin
        syscall        ; Call sys_read

        cmp rax, 0  ; Check the return status code to be 0
        je Exit     ; If the status code is 0, that mean EOF, exit

        cmp byte [Buff], 61h  ; Test input char against lowecase 'a'
        jb Write              ; If below 'a' in ASCII, not lower case
        cmp byte [Buff], 7Ah  ; Test input char against lowercase 'z'
        ja Write ; If above 'z' in ASCII, not lowercase

        ; At this point, we have a lowercase character
        sub byte [Buff], 20h ; Subtracting 20h to make uppercase
        ; And then write out the character to stdout

    Write:
        mov rax, 1    ; Kernal call: sys_write
        mov rdi, 1    ; File descriptor = 1, stdout
        mov rsi, Buff ; Pass buffer addr offset to write
        mov rdx, 1    ; Write one character to stdout
        syscall       ; Call sys_write
        jmp Read      ; Read new character from the stdin


    ; End of the program, exit with return code 0
    Exit:
        mov rax, 60  ; Kernal call syscall_exit
        mov rdi, 0   ; Return code value
        syscall      ; Call sys_exit
