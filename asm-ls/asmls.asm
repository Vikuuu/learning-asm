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

;--------------------------------------------------
;  UNINITIALISED DATA
;--------------------------------------------------
SECTION .bss
    current_path_buf     resb 256
    CURRENT_PATH_BUF_LEN equ $-current_path_buf

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
; In            : RSI(buff offset), rdx(buff len)
; Returns       : R15(return code)
; Modifies      : Nothing
; Calls         : Syscall sys_write
; Description   : Prints the given message in RSI

Print:
    push rax ; Save caller's register
    push rbx

    mov rax, 1 ; Syscall sys_write code
    mov rax, 1 ; File descriptor 1: Standard out
    syscall

    mov r15, rax

    pop rbx ; Restore caller's register
    pop rax

    ret


GLOBAL _start ; Linked needs this to find starting point

_start:

    call Getwd
    cmp r15, 0   ; Compare the return code
    jl ErrorExit ; If -ve return value, exit with error msg
    mov rsi, current_path_buf ; Pointer to buffer
    mov rdx, r15              ; Length of buffer
    call Print
    cmp r15, 0   ; Compare the return code
    jl ErrorExit ; If -ve return code, exit with error msg

    call Exit
