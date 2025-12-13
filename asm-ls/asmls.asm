;--------------------------------------------------------------------------------
; Executable Name   : asmls
; Version           : 1.0
; Created At        : 2025-12-13
; Updated At        : 
; Author            : Guts Thakur
; Updated By        :
; Description       : This is the linux utility function `ls`,
;                   written in x86_64 asm
;--------------------------------------------------------------------------------

;--------------------------------------------------
;  INITIALISED DATA
;--------------------------------------------------
SECTION .data
    error_msg       db "Error encountered", 0Ah
    ERROR_MSG_LEN   equ $-error_msg
    new_line        db 0Ah
    NEW_LINE_LEN    equ $-new_line
    dot             db ".", 0

;--------------------------------------------------
;  UNINITIALISED DATA
;--------------------------------------------------
SECTION .bss
    current_path_buf     resb 256
    CURRENT_PATH_BUF_LEN equ $-current_path_buf

    dir_buff     resb 4096
    DIR_BUFF_LEN equ $-dir_buff

    dir_fd resq 1

;--------------------------------------------------
;  PROCEDURES
;--------------------------------------------------
SECTION .text

;--------------------------------------------------
; ErrorExit     : Exit on error
; In            : Nothing
; Returns       : Nothing
; Modifies      : Nothing
; Calls         : Syscall sys_exit
; Description   : Exits the program on error, with error code 1(not zero), 
;               indicating failure and prints the a message.

ErrorExit:
    mov rax, 1             ; Syscall sys_write code
    mov rdi, 2             ; File descriptor 2: Standard Error
    mov rsi, error_msg     ; Error message to print
    mov rdx, ERROR_MSG_LEN ; Length of error message
    syscall

    mov rax, 60 ; Syscall sys_exit code
    mov rdi, 1  ; Return code
    syscall

;--------------------------------------------------
; Exit          : Exits the program
; In            : Nothing
; Returns       : Nothing
; Modifies      : Nothing
; Calls         : Syscall sys_exit
; Description   : Exits the program with the success code (code = 0)

Exit:
    mov rax, 60 ; Syscall sys_exit code
    mov rdi, 0  ; Return code
    syscall 

;--------------------------------------------------
; Getwd         : Gets current working directory
; In            : Nothing
; Returns       ; r15(syscall return value)
; Modifies      ; current_path_buf
; Calls         : Syscall sys_getwd
; Description   : Gets the current working directory's absolute
;               path and puts it in the `current_path_buf`

Getwd:
    push rax ; Save caller's registers
    push rbx
    push rcx
    push rdx
    push rdi 
    push rsi

    mov rax, 79                   ; Syscall sys_getwd code
    mov rdi, current_path_buf     ; Offset of the buffer
    mov rsi, CURRENT_PATH_BUF_LEN ; Length of the buffer
    syscall

    mov r15, rax ; Save the returned value

    pop rsi ; Restore caller's registers
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret

;--------------------------------------------------
; Print         : print the given message
; In            : RSI(buff offset), RDX(buff len)
; Returns       : R15(return code)
; Modifies      : Nothing
; Calls         : Syscall sys_write
; Description   : Prints the given message in RSI

Print:
    push rax ; Save caller's register
    push rbx
    push rsi
    push rdx

    mov rax, 1 ; Syscall sys_write code
    mov rdi, 1 ; File descriptor 1: Standard out
    syscall

    mov r15, rax

    pop rdx
    pop rsi
    pop rbx ; Restore caller's register
    pop rax

    ret

;--------------------------------------------------
; PrintNewLine  : prints new line
; In            : Nothing
; Returns       : R15(return code)
; Modifies      : Nothing
; Calls         : Syscall sys_write
; Description   : Prints the New line

PrintNewLine:
    push rax ; Save caller's register
    push rdi
    push rsi
    push rdx

    mov rax, 1 ; Syscall sys_write code
    mov rdi, 1 ; File descriptor 1: Standard out
    mov rsi, new_line ; Offset of new_line buf
    mov rdx, NEW_LINE_LEN ; Length of the buf
    syscall

    mov r15, rax ; Save the return code

    pop rdx ; Restore caller's register
    pop rsi
    pop rdi
    pop rax

    ret


GLOBAL _start ; Linked needs this to find starting point

_start:
    mov rax, 257 ; Syscall sys_openat code
    mov rdi, -100 ; value of AT_FDCWD
    mov rsi, dot ; "."
    mov rdx, 0x10000 ; O_DIRECTORY
    syscall

    cmp rax, -1 ; Compare return code
    je ErrorExit

    mov [dir_fd], rax ; Save the returned fd

ReadDir:
    mov rax, 217 ; Syscall sys_getdents64 code
    mov rdi, [dir_fd]; file descriptor
    lea rsi, [dir_buff] ; Load effective address of `dir_buff`
    mov rdx, DIR_BUFF_LEN ; count
    syscall

    cmp rax, 0 ; compare the return code
    jl ErrorExit ; if -ve, error encountered
    je done ; if 0 we are done

    mov rcx, rax ; move bytes_read
    lea rbx, [dir_buff] ; load efeective address of `dir_buff`

    next:
        movzx rdx, word [rbx + 16] ; move to the d_reclen
        cmp rdx, 0 ; compare the d_reclen value
        jz done ; if zero we are done
        lea rsi, [rbx + 19] ; move to the d_name

        push rdx ; save the rdx
        xor r8, r8; clear out r8
        .find:
            cmp byte [rsi + r8], 0 ; compare with the null_byte
            je .len_found ; we found the null_byte jump to len_found
            inc r8 ; increment the length
            jmp .find ; reiterate to find the null_byte
        .len_found:
            ; save the length of the file name in rdx
            ; preparing for the sys_write call
            ; file name already pointed by rsi
            mov rdx, r8 
            call Print
            call PrintNewLine
        pop rdx ; restore the rdx value
        
        add rbx, rdx ; move the file name ahead by the d_reclen
        jmp next
    done:
        mov rax, 3 ; sys_close
        mov rdi, [dir_fd]
        syscall 

        call Exit
