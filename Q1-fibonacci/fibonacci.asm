default rel
; ============================================================================
; COC3092 - Microprocessor Theory & Applications
; Assignment - II, Question 1
; Fibonacci series - 'n' terms (x86 / x86-64, NASM, Intel syntax)
;
; Called from C as:  fibonacci(int n)
;   - n arrives in EDI (System V AMD64 calling convention, 1st integer arg).
;   - This routine prints the first n terms: 0, 1, 1, 2, 3, 5, 8, ...
;   - Logic: a = 0, b = 1; repeat n times: print a, next = a + b,
;            a = b, b = next.
;   - 32-bit integer arithmetic (EAX/EBX) is used for the series values,
;     which is the x86 part of the question; the 64-bit registers only
;     carry the calling-convention / stack frame.
;
; Registers used (all callee-saved, so C's values survive the call):
;   R12D = n (loop limit)      EBX = a (term to print)
;   R13D = b (next term)       R14D = i (terms printed so far)
; ============================================================================

        global  fibonacci       ; make the routine visible to the C linker
        extern  printf          ; C library print routine we call

        section .rodata
fmt_term:   db  "%d ", 0        ; format for one term, with a trailing space
fmt_nl:     db  10, 0           ; "\n" - newline printed after the series

        section .text
fibonacci:
        push    rbp             ; save the caller's base pointer
        mov     rbp, rsp        ; set up our own stack frame
        push    rbx             ; save RBX (we will use EBX for 'a')
        push    r12             ; save R12 (we will use R12D for 'n')
        push    r13             ; save R13 (we will use R13D for 'b')
        push    r14             ; save R14 (we will use R14D for 'i')

        mov     r12d, edi       ; R12D = n, the number of terms to print
        xor     ebx, ebx        ; a = 0, the first Fibonacci term
        mov     r13d, 1         ; b = 1, the second Fibonacci term
        xor     r14d, r14d      ; i = 0, no terms printed yet

.loop:                          ; ---- start of one iteration ----
        cmp     r14d, r12d      ; compare i with n
        jge     .done           ; if i >= n, all terms are printed, exit loop

        ; printf("%d ", a)
        lea     rdi, [rel fmt_term]   ; RDI = 1st arg: format string "%d "
        mov     rsi, rbx        ; RSI = 2nd arg: a (zero-extended from EBX)
        xor     eax, eax        ; AL = 0: no floating-point args for printf
        call    printf wrt ..plt          ; print the current term

        ; next = a + b   (EAX is a scratch register here)
        mov     eax, ebx        ; EAX = a
        add     eax, r13d       ; EAX = a + b = next term
        mov     ebx, r13d       ; a = old b (shift the pair forward)
        mov     r13d, eax       ; b = next term

        inc     r14d            ; i = i + 1 (one more term printed)
        jmp     .loop           ; ---- repeat for the next term ----

.done:
        ; printf("\n") - end the line after the last term
        lea     rdi, [rel fmt_nl]     ; RDI = format string "\n"
        xor     eax, eax        ; AL = 0: no floating-point args
        call    printf wrt ..plt

        pop     r14             ; restore R14 (reverse order of the pushes)
        pop     r13             ; restore R13
        pop     r12             ; restore R12
        pop     rbx             ; restore RBX
        pop     rbp             ; restore the caller's base pointer
        ret                     ; return to C (main)

        section .note.GNU-stack noalloc noexec nowrite progbits
