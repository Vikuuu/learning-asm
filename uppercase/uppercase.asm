; Executable name: uppercase
; Version: 1.0
; Created at: 2025-11-19
; Updated at: 2025-12-02
; Author: Guts
; Description: Convert any lowercase letter to uppercase

SECTION .bss           ; Section containing unintialized data
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
        mov rdx, BuffLen  ; Read 1 character from stdin
        syscall           ; Call sys_read
        mov r12, rax      ; move sys_call return value
        ; Error handling
        cmp r12, -1
        je Error
        cmp rax, 0        ; Check the return status code to be 0
        je Done           ; If the status code is 0, that mean EOF, exit

        ; Set up registers for the process buffer step:
        mov rbx, rax  ; Place the number of bytes to read into rbx
        mov r13, Buff ; Place the address of Buff in r13
        ; dec r13       ; Adjust r13 to offset by one.

    Scan:
        cmp byte [r13-1+rbx], 61h  ; Test input char against lowecase 'a'
        jb .Next                 ; If below 'a' in ASCII, not lower case
        cmp byte [r13-1+rbx], 7Ah  ; Test input char against lowercase 'z'
        ja .Next                 ; If above 'z' in ASCII, not lowercase
        ; At this point, we have a lowercase character
        sub byte [r13-1+rbx], 20h ; Subtracting 20h to make uppercase
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
        mov rdx, r12     ; Write one character to stdout
        syscall          ; Call sys_write
        mov r12, rax
        cmp r12, -1
        je Error
        jmp Read         ; Read new character from the stdin

    ; End of the program, exit with return code 0
    Done:
        ; Set up for sys_exit
        mov rax, 60  ; Kernal call syscall_exit
        mov rdi, 0   ; Return code value
        syscall      ; Call sys_exit

    Error:
        ; Set up for sys_exit
        mov rax, 60
        mov rdi, 1
        syscall
