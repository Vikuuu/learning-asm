;--------------------------------------------------------------------------------
; Executable name : eatmacro
; Created date    : 2025-12-08
; Author          : Guts
; Description     : A simple program in asm for linux, demonstrating
;                   the use of escape sequences to do simple "full-screen"
;                   text output to a terminal like Konsole.
;                   Demonstrating the use of macro's.
;--------------------------------------------------------------------------------

SECTION .data; Section containing initialised data

	SCRWIDTH  equ 80; Default is 80 char wide
	PosTerm   db 27, "[01;01H"; <ESC>[<Y>; <X>H
	POSLEN    equ $-PosTerm; Length of term position string
	ClearTerm db 27, "[2J"; <ESC>[2J
	CLEARLEN  equ $-ClearTerm; Length of term clear string
	AdMsg     db "Eat At Joe's!";Ad message
	ADLEN     equ $-AdMsg; Length of ad message
	Prompt    db "Press Enter: "; User prompt
	PROMPTLEN equ $-Prompt; Length of user prompt

	; This table gives us pairs of ASCII digits from 0-80. Rather than
	; calculate ASCII digits to insert in the terminal control string
	; we look them up in the table and read back two digits at once to
	; a 16-bit register like DX, which we then poke into the terminal
	; control string PosTerm at the appropriate place. See GotoXY.
	; If you intend to work on a larger console than 80X80, you must
	; add additional ASCII digit encoding to the end digits. Keep in
	; mind that the code shown here will only work up to 99X99.

Digits: db "0001020304050607080910111213141516171819"
        db "2021222324252627282930313233343536373839"
        db "4041424344454647484950515253545556575859"
        db "606162636465666768697071727374757677787980"

SECTION .bss; Section containing uninitialized data

SECTION .text; Section containing code

;--------------------------------------------------------------------------------
; ExitProg: Exit the program
; In: nothing
; Returns: nothing
; Modifies: nothing

%macro ExitProg 0
    mov rsp, rbp ; Stack alignment epilogue
    pop rbp

    mov rax, 60;
    mov rdi, 0
    syscall
%endmacro

;--------------------------------------------------------------------------------
; WaitEnter

%macro WaitEnter 0
    mov rax, 0 ; SYSCALL sys_read
    mov rdi, 0 ; File descriptor 0: stdin
    syscall 
%endmacro

;--------------------------------------------------------------------------------
; ClrScr: Clear the Linux console
; Updated:
; In: Nothing
; Returns: Nothing
; Modifies: Nothing
; Calls: SYSCALL sys_write
; Description: Sends the predefined control Estring to the
; console, which clears the full display

%macro ClrScr 0
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

	WriteStr ClearTerm, CLEARLEN; Send control string to console

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro


;--------------------------------------------------------------------------------
; GotoXY: Position the Linux console cursor to an X, Y position
; Updated:
; In: X in AH, Y in AL
; Returns: Nothing
; Modifies; PosTerm terminal control sequence string
; Calls: SYSCALL sys_write
; Description: Prepares a terminal control string for the X, Y
; coordinates passed in AL and AH and calls sys_write to position the console cursor to that X, Y position.
; Writing text to the console after calling GotoXY will
; begin display of text at that X, Y position.

%macro GotoXY 2 ; %1 get X, %2 gets Y
    push rdx
    push rcx
    push rbx
    push rax
    push rsi
    push rdi

	xor rbx, rbx; Zero rbx
	xor rcx, rcx; Zero rcx

	;   Poke the Y digits:
	mov bl, %2; Put Y value into scale term RBX
	mov cx, [Digits+rbx*2]; Fetch decimal digits to CX
	mov [PosTerm+2], cx; Poke digits into control string

	;   Poke the X digits:
	mov bl, %1; Put X value into scale term RBX
	mov cx, [Digits+rbx*2]; Fetch decimal digits to CX
	mov [PosTerm+5], cx; Poke digits into control string

	;    Send control sequence to stdout:
	WriteStr PosTerm, POSLEN; Send control string to the console

    pop rdi
    pop rsi
    pop rax
    pop rbx
    pop rcx
    pop rdx
%endmacro


;--------------------------------------------------------------------------------
; WriteCtr: Send a string centered to an 80-char wide Linux console
; update:
; In: Y value in AL, String addr. in RSI, string length in RDX
; Returns: Nothing
; Modifies: PosTerm terminal control sequence string
; Calls: GotoXY, WriteStr
; Description: Displays a string to the Linxu console centered in an
; 80-column display. Calculates the X for the passed-in
; string length, then calls GotoXY and WriteStr to send
; the string to the console

%macro WriteCtr 3; %1 = Y value in AL, %2 = String addr, %3 = string length
    push rbx
    push rdx

    mov rdx, %3; Load string length
	xor  rbx, rbx; Zero rbx
	mov  bl, SCRWIDTH; Load the screen width value to BL
	sub  bl, dl; Take diff of screen widht and string length
	shr  bl, 1; Divide difference by two for X value
	;mov  ah, bl; GotoXY requires X value in AH
	GotoXY bl, %1; Position the cursor for display
	WriteStr %2, %3; Write the string to the console

    pop rdx
    pop rbx
%endmacro


	;--------------------------------------------------------------------------------
	; WriteStr: Send a string to the Linux console
	; Update:
	; In: String address in RSI, string length in RDX
	; Returns: Nothing
	; Modifies: Nothing
	; Calls: SYSCALL sys_write
	; Description; Displays a string to the Linux console through
	; a sys_write kernel call

%macro WriteStr 2 ; %1 = string address, %2 = string length
    push r11
    push rax
    push rcx

	mov     rax, 1; Specify sys_write call
	mov     rdi, 1; Specify File Descriptor 1: Stdout
    mov     rsi, %1; Put string address offset in rsi
    mov     rdx, %2; Put string length in rdx
	syscall ; Make the kernel call

	pop rcx; Restore pertinent registers
	pop rax
    pop r11
%endmacro

	ret; Go Home

GLOBAL _start

_start:
    push rbp ; Alignment prolog
    mov rbp, rsp
    ;and rasp, -16

; First we clear terminal display...
    ClrScr
; Then we post the ad message centered on the 80-wide console:
    WriteCtr 12, AdMsg, ADLEN
; Position the cursor for the "Press Enter" message:
    GotoXY 1, 23
; Display "Press Enter" prompt:
    WriteStr Prompt, PROMPTLEN
; Wait for the user to press Enter:
    WaitEnter
; And we're done!
    ExitProg
