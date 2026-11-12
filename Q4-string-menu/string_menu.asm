default rel
; ============================================================================
; COC3092 - Microprocessor Theory & Applications
; Assignment - II, Question 4
; Menu-driven string operations (x86 / x86-64, NASM, Intel syntax)
;
; Called from C as:  string_menu(char *str)
;   - RDI = str (pointer to the string C read from the user).
;   - Shows a menu in a loop until the user picks 6 (Exit):
;       1. Display the string
;       2. Find the length of the string
;       3. Reverse the string (on a copy, so the original is unchanged)
;       4. Check whether the string is a palindrome
;       5. Search the string for a given character
;       6. Exit
;   - The length is counted once, up front, by scanning for the '\0'
;     terminator. Palindrome means the string reads the same forwards
;     and backwards, e.g. "naman" or "madam".
;
; Registers used (all callee-saved, so C's values survive the call):
;   R12  = str (original string)   R13D = length of the string
;   R14D = left index / loop index R15D = right index / loop index
;   EBX  = one byte being compared (also callee-saved); in option 3 it
;          temporarily holds the rev_buf base address instead
; ============================================================================

        global  string_menu     ; make the routine visible to the C linker
        extern  printf          ; C library print routine we call
        extern  scanf           ; C library input routine we call

        section .rodata
menu_text:      db  10, "--- String Menu ---", 10
                db  "1. Display the string", 10
                db  "2. Find the length of the string", 10
                db  "3. Reverse the string", 10
                db  "4. Check whether the string is a palindrome", 10
                db  "5. Search for a character", 10
                db  "6. Exit", 10
                db  "Enter your choice (1-6): ", 0
fmt_int:        db  "%d", 0             ; read the menu choice (an int)
fmt_char:       db  " %c", 0            ; read one char; leading space skips
                                        ; the newline left by the last scanf
msg_display:    db  "String: %s", 10, 0
msg_length:     db  "Length: %d", 10, 0
msg_reverse:    db  "Reversed string: %s", 10, 0
msg_pal_yes:    db  "The string is a palindrome.", 10, 0
msg_pal_no:     db  "The string is not a palindrome.", 10, 0
msg_search_in:  db  "Enter the character to search for: ", 0
msg_found:      db  "Character '%c' is present in the string.", 10, 0
msg_notfound:   db  "Character '%c' is not present in the string.", 10, 0
msg_invalid:    db  "Invalid choice. Please enter a number from 1 to 6.", 10, 0
msg_exit:       db  "Exiting menu.", 10, 0

        section .bss
choice:         resd    1               ; the menu choice read by scanf
search_ch:      resb    1               ; the character to search for
rev_buf:        resb    256             ; copy of the string, for reversing

        section .text
string_menu:
        push    rbp             ; save the caller's base pointer
        mov     rbp, rsp        ; set up our own stack frame
        push    rbx             ; save RBX (used for one byte at a time)
        push    r12             ; save R12 (str pointer)
        push    r13             ; save R13 (length)
        push    r14             ; save R14 (left / loop index)
        push    r15             ; save R15 (right / loop index)
        sub     rsp, 8          ; keep the stack 16-byte aligned for calls

        mov     r12, rdi        ; R12 = str, the string from C

        ; ---- Count the length: scan until the '\0' terminator ----
        xor     r13d, r13d      ; length = 0
.len_loop:
        cmp     byte [r12 + r13], 0     ; is str[length] the terminator?
        je      .len_done       ; yes, length is complete
        inc     r13d            ; length = length + 1
        jmp     .len_loop       ; check the next character
.len_done:

.menu_loop:                     ; ---- show the menu, read a choice ----
        lea     rdi, [rel menu_text]  ; RDI = menu text
        xor     eax, eax        ; AL = 0: no floating-point args for printf
        call    printf wrt ..plt

        lea     rdi, [rel fmt_int]    ; RDI = "%d"
        lea     rsi, [rel choice]     ; RSI = address to store the choice in
        xor     eax, eax        ; AL = 0
        call    scanf wrt ..plt

        ; Dispatch on the choice (1-6). Anything else is invalid.
        cmp     dword [choice], 1
        je      .opt_display
        cmp     dword [choice], 2
        je      .opt_length
        cmp     dword [choice], 3
        je      .opt_reverse
        cmp     dword [choice], 4
        je      .opt_palindrome
        cmp     dword [choice], 5
        je      .opt_search
        cmp     dword [choice], 6
        je      .opt_exit

        lea     rdi, [rel msg_invalid]
        xor     eax, eax
        call    printf wrt ..plt
        jmp     .menu_loop      ; invalid choice: show the menu again

.opt_display:                   ; ---- 1. Display the string ----
        lea     rdi, [rel msg_display]
        mov     rsi, r12        ; RSI = str
        xor     eax, eax
        call    printf wrt ..plt
        jmp     .menu_loop

.opt_length:                    ; ---- 2. Find the length ----
        lea     rdi, [rel msg_length]
        mov     esi, r13d       ; RSI = length
        xor     eax, eax
        call    printf wrt ..plt
        jmp     .menu_loop

.opt_reverse:                   ; ---- 3. Reverse the string ----
        ; RBX = rev_buf address. (RIP-relative + an index register cannot
        ; be encoded in one instruction, so the buffer is reached through
        ; a base register instead of [rev_buf + index].)
        lea     rbx, [rel rev_buf]
        ; Step 1: copy str into rev_buf, including the '\0' terminator.
        xor     r14d, r14d      ; i = 0
.copy_loop:
        mov     al, [r12 + r14]         ; AL = str[i]
        mov     [rbx + r14], al         ; rev_buf[i] = str[i]
        cmp     al, 0           ; was it the terminator?
        je      .copy_done      ; yes, the copy is complete
        inc     r14d            ; i = i + 1
        jmp     .copy_loop
.copy_done:
        ; Step 2: reverse rev_buf in place. left = 0, right = length - 1;
        ; swap rev_buf[left] and rev_buf[right], then move both inwards.
        xor     r14d, r14d      ; left = 0
        mov     r15d, r13d      ; right = length
        dec     r15d            ; right = length - 1
.rev_loop:
        cmp     r14d, r15d      ; compare left with right
        jge     .rev_done       ; if left >= right, the reversal is done
        mov     al, [rbx + r14]         ; AL = rev_buf[left]
        mov     dl, [rbx + r15]         ; DL = rev_buf[right]
        mov     [rbx + r14], dl         ; rev_buf[left]  = old right byte
        mov     [rbx + r15], al         ; rev_buf[right] = old left byte
        inc     r14d            ; left = left + 1
        dec     r15d            ; right = right - 1
        jmp     .rev_loop
.rev_done:
        lea     rdi, [rel msg_reverse]
        lea     rsi, [rel rev_buf]    ; RSI = the reversed copy
        xor     eax, eax
        call    printf wrt ..plt
        jmp     .menu_loop

.opt_palindrome:                ; ---- 4. Check palindrome ----
        ; Compare str[left] with str[right], moving inwards from both ends.
        ; The first mismatch means "not a palindrome".
        xor     r14d, r14d      ; left = 0
        mov     r15d, r13d      ; right = length
        dec     r15d            ; right = length - 1
.pal_loop:
        cmp     r14d, r15d      ; compare left with right
        jge     .is_pal         ; if left >= right, all pairs matched
        mov     al, [r12 + r14] ; AL = str[left]
        mov     bl, [r12 + r15] ; BL = str[right]
        cmp     al, bl          ; are the two ends equal?
        jne     .not_pal        ; no, so it is not a palindrome
        inc     r14d            ; left = left + 1
        dec     r15d            ; right = right - 1
        jmp     .pal_loop
.is_pal:
        lea     rdi, [rel msg_pal_yes]
        xor     eax, eax
        call    printf wrt ..plt
        jmp     .menu_loop
.not_pal:
        lea     rdi, [rel msg_pal_no]
        xor     eax, eax
        call    printf wrt ..plt
        jmp     .menu_loop

.opt_search:                    ; ---- 5. Search for a character ----
        lea     rdi, [rel msg_search_in]
        xor     eax, eax
        call    printf wrt ..plt

        lea     rdi, [rel fmt_char]   ; RDI = " %c" (space skips leftover newline)
        lea     rsi, [rel search_ch]  ; RSI = address to store the character in
        xor     eax, eax
        call    scanf wrt ..plt

        ; Scan the string for that character.
        xor     r14d, r14d      ; i = 0
        lea     rax, [rel search_ch]    ; RAX = address of the character
        movzx   ebx, byte [rax]         ; EBX = the character to find
.search_loop:
        cmp     r14d, r13d      ; compare i with length
        jge     .search_miss    ; if i >= length, it was not found
        movzx   eax, byte [r12 + r14]   ; EAX = str[i]
        cmp     eax, ebx        ; compare str[i] with the character
        je      .search_hit     ; equal, so it is present
        inc     r14d            ; i = i + 1
        jmp     .search_loop
.search_hit:
        lea     rdi, [rel msg_found]
        mov     esi, ebx        ; RSI = the character that was found
        xor     eax, eax
        call    printf wrt ..plt
        jmp     .menu_loop
.search_miss:
        lea     rdi, [rel msg_notfound]
        mov     esi, ebx        ; RSI = the character that was not found
        xor     eax, eax
        call    printf wrt ..plt
        jmp     .menu_loop

.opt_exit:                      ; ---- 6. Exit ----
        lea     rdi, [rel msg_exit]
        xor     eax, eax
        call    printf wrt ..plt

        add     rsp, 8          ; undo the alignment adjustment
        pop     r15             ; restore R15 (reverse order of the pushes)
        pop     r14             ; restore R14
        pop     r13             ; restore R13
        pop     r12             ; restore R12
        pop     rbx             ; restore RBX
        pop     rbp             ; restore the caller's base pointer
        ret                     ; return to C (main)

        section .note.GNU-stack noalloc noexec nowrite progbits
