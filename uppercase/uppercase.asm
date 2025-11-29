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

; Psuedocode refinement no. 3
; Read: Set up registers for the sys_read kernal call.
;       Call sys_read to read a buffer full of characters from stdin.
;       Test for EOF.
;       If we're at EOF, jump to Exit
;       
;       Set up registers as a pointer to scan the buffer.
; Scan: Test the character at buffer pointer to see if it's lowercase
;       If it's not a lowercase character, skip conversion
;       Convert the character to uppercase by subtracting 20h
;       Decrement buffer pointer.
;       If we still have characters in the buffer, jump to scan.
;
; Write: Set up registers for the Write kernal call
;        Call sys_write to write the processed buffer to stdout
;        Jump back to Read and get another buffer full of characters
;
; Exit: Set up registers for the sys_exit kernal call.
;       Call sys_exit.

; Psuedocode refinement no. 4
; Read: Set up registers for the sys_read kernal call.
;       Call sys_read to read a buffer full of characters from stdin.
;       Store the number of characters read in RSI
;       Test for EOF (rax = 0).
;       If we're at EOF, jump to Exit
;
;       Put the address of the buffer in rsi.
;       Put the number of characters read into the buffer in rdx.
;
; Scan: Compare the byte at [r13 + rbx] against 'a'.
;       If the byte is below 'a' in the ASCII sequence, jumpt to Next
;       Compare the byte at [r13 + rbx] against 'z'.
;       If the byte is above 'z' in the ASCII sequence, jump to Next.
;       Subtract 20h from the byte at [r13 + rbx].
;
; Next: Decrement rbx by one.
;       Jump if not zero to Scan
;
; Write: Set up registers for the sys_write kernal call.
;        Call sys_write call, to write to the stdout.
;        Jump back to Read and get another buffer full of character.
;
; Exit: Set up registers for the sys_exit kernal call.
;       Call sys_exit kernal call.

SECTION .bss   ; Section containing unintialized data
    BuffLen equ 128    ; Length of buffer
    Buff: resb BuffLen ; Text Buffer

SECTION .data  ; Section containing intialized data

SECTION .text     ; Section containing code
    global _start ; Linker need this, to find the starting point

_start:
    mov rbp, rsp ; For correct debugging

    Read:
        ; Set up for sys_read kernal call
        mov rax, 0        ; Kernal call: sys_read
        mov rdi, 0        ; File descriptor = 0, stdin
        mov rsi, Buff     ; Pass buffer addr to read to
        mov rdx, BuffLen ; Read 1 character from stdin
        syscall           ; Call sys_read
        mov r12, rax   ; move sys_call return value
        cmp rax, 0  ; Check the return status code to be 0
        je Done ; If the status code is 0, that mean EOF, exit

        ; Set up registers for the process buffer step:
        mov rbx, rax  ; Place the number of bytes to read into rbx
        mov r13, Buff ; Place the address of Buff in r13
        dec r13       ; Adjust r13 to offset by one.

    Scan:
        cmp byte [r13+rbx], 61h  ; Test input char against lowecase 'a'
        jb .Next ; If below 'a' in ASCII, not lower case
        cmp byte [r13+rbx], 7Ah  ; Test input char against lowercase 'z'
        ja .Next ; If above 'z' in ASCII, not lowercase
        ; At this point, we have a lowercase character
        sub byte [r13+rbx], 20h ; Subtracting 20h to make uppercase
    ; Check we have read all the buffer or not.
    .Next:
        dec rbx    ; Decrement the counter by 1
        cmp rbx, 0
        jnz Scan   ; If character remains, loop back(if rbx not 0)

    ; And then write out the character to stdout

    Write:
        ; Set up for sys_write
        mov rax, 1       ; Kernal call: sys_write
        mov rdi, 1       ; File descriptor = 1, stdout
        mov rsi, Buff    ; Pass buffer addr offset to write
        mov rdx, r12 ; Write one character to stdout
        syscall          ; Call sys_write
        jmp Read         ; Read new character from the stdin


    ; End of the program, exit with return code 0
    Done:
        ; Set up for sys_exit
        mov rax, 60  ; Kernal call syscall_exit
        mov rdi, 0   ; Return code value
        syscall      ; Call sys_exit
