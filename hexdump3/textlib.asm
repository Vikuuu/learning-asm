; Library name: textlib
; Version: 2.0
; Created data: 2025-12-07
; Author : Guts Thakur
; Description: A simple include library demonstrating the use of 
;              the %INCLUDE directive within SASM
; Note that this file cannot be assembed by itself

SECTION .bss        ; Section containing uninitialized data
    BUFFLEN EQU 10h
    Buff    resb BUFFLEN

SECTION .data       ; Section containing initialised data

    ; Here we have two parts of a single usefull data structure, implementing
    ; the text line of a hex dump utitlity. The first part displays 16 bytes
    ; in hex separated by spaces. Immediately following is a 16-character
    ; line delimited by vertical bar characters. Because they are adjacent,
    ; the two parts can be referenced separately or as a single contiguous
    ; unit. Remeber that if DumpLine is to be used separately, you must
    ; append an EOL before sending it to the Linux console.
    DumpLine: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
    DUMPLEN   EQU $-DumpLine
    ASCLine:  db "|................|", 0Ah
    ASCLEN    EQU $-ASCLine
    FULLLEN   EQU $-DumpLine

    ; The HexDigits table is used to convert numeric values to their hex
    ; eequivalents. Index by nybble without a scale: [HexDigits+eax]
    HexDigits: db "0123456789ABCDEF"

    ; This table is used for ASCII character translation, into the ASCII
    ; portion of the hex dump line, via XLAT or ordinary memory lookup.
    ; All printable characters "play through" as themselves. The high 128
    ; characters are translated to ASCII period (2Eh). The non-printable 
    ; characters in the low 128 are also translated to ASCII period, as is
    ; char 127.
    DotXlat:
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh ;  32- 47
        db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh ;  48- 63
        db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh ;  64- 79
        db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh ;  80- 95
        db 60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh ;  96-111
        db 70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,71h,7Dh,7Eh,2Eh ; 112-127
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh

SECTION .text ; Section containing code

;--------------------------------------------------------------------------------
; ClearLine   : Clear a hex dump line string to 16 0 values
; Input       : nothing
; Returns     : nothing
; Modifies    : nothing
; Calls       : DumpChar
; Description : The hex dump line string is cleared to binary 0 by 
;               calling DumpChar 16 times, passing it 0 each time.
;--------------------------------------------------------------------------------
ClearLine:
    push rax ; Save all caller's r*x GP registers
    push rbx
    push rcx
    push rdx
    mov rdx, 15 ; We're going to go 16 pokes, counting from 0
.poke:
    mov rax, 0 ; Tell DumpChar to poke a '0'
    call DumpChar ; Insert the '0' into the hex dump string
    sub rdx, 1 ; DEC doesn't affect CF!
    jae .poke ; Loop back if RDX >= 0

    pop rdx ; Restore caller's r*x GP registers
    pop rcx
    pop rbx
    pop rax
    ret ; Return to caller

;--------------------------------------------------------------------------------
; DumpChar    : "Poke" a value into the hex dump line string.
; Input       : Pass the 8-bit value to be poked in RAX.
;               Pass the value's position in the line (0-15) in RDX.
; Returns     : Nothing
; Modifies    : RAX, ASCLine, DumpLine
; Calls       : Nothing
; Description : The value passed in RAX will be put in both the hex dump
;               portion and in the ASCII portion, at the position passed
;               in RDX, represented by a space where it is not a
;               printable character.
;--------------------------------------------------------------------------------
DumpChar:
    push rbx ; Save caller's RBX
    push rdi ; Save caller's RDI

; First we insert the input char into the ASCII part of the dump line
    mov bl, [DotXlat+rax]   ; Translate nonprintables to '.'
    mov [ASCLine+rdx+1], bl ; Write to ASCII portion

; Next we insert the hex equivalent of the input char in the hex
; part of the hex dump line:
    mov rbx, rax         ; Save a second copy of the input char
    lea rdi, [rdx*2+rdx] ; CAlc offset into line string (RDX * 3)

; Look up low nybble character and insert it into the string:
    and rax, 000000000000000Fh ; Mask out all but the low nybble
    mov al, [HexDigits+rax]    ; Look up the char equiv. of nybble
    mov [DumpLine+rdi+2], al   ; Write the char equiv. to line string

; Look up high nybble character and insert it into the string:
    and rbx, 00000000000000F0h ; Mask out all but the high nybble
    shr rbx, 4                 ; Shift high 4 bits of byte into low 4 bits
    mov bl, [HexDigits+rbx]    ; Look up char equiv. of nybble
    mov [DumpLine+rdi+1], bl   ; Write the char equiv. to line string

; Done! Let's return:
    pop rdi ; Restore caller's RDI
    pop rbx ; Restore callers' rbx
    ret ; Return to caller

;--------------------------------------------------------------------------------
; PrintLine   : Displays DumpLine to stdout
; In          : DumpLine, FULLLEN
; Returns     : Nothing
; Modifies    : Nothing
; Calls       : Kernel sys_write
; Description : The hex dump line string DumpLine is displayed to
;               stdout using syscall function sys_write. Registers
;               used are preserved.
;--------------------------------------------------------------------------------
PrintLine:
    ; Save caller's registers
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rax, 1        ; Specify sys_write call
    mov rdi, 1        ; Specify file descriptor 1: Standart output
    mov rsi, DumpLine ; Pass address of line string
    mov rdx, FULLLEN  ; Pass size of line string
    syscall           ; Make kernal call

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret ; Return to caller

;--------------------------------------------------------------------------------
; LoadBuff    : Fills a buffer with data from stdin via syscall sys_read
; In          : Nothing
; Returns     : # bytes read in R15
; Modifies    : RCX, R15, Buff
; Calls       : syscall sys_read
; Description : Loads a buffer full of data (BUFFLEN bytes) from stdin
;               using syscall sys_read and places it in Buff. Buffer
;               offset counter RCX is zeroed, because we're starting in
;               on a new buffer full of data. Caller must test value in
;               R15: If R15 contains 0 on return, we've hit EOF on stdin.
;               < 0 in r15 on return indicates some kind of error.
;--------------------------------------------------------------------------------

LoadBuff:
    push rax ; save caller's rax
    push rdx
    push rsi
    push rdi

    mov rax, 0 ; Specify sys_read call
    mov rdi, 0 ; Specify File desriptor 0: Standard input
    mov rsi, Buff ; Pass offset of the buffer to read to
    mov rdx, BUFFLEN ; Pass number of bytes to read at one pass
    syscall ; Call syscall
    mov r15, rax ; Save # of bytes read from file for later use
    xor rcx, rcx ; Clear buffer pointer RCX to 0

    pop rdi ; Restore caller's RDI
    pop rsi
    pop rdx
    pop rax
    ret
