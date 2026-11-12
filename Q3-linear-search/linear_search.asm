; ============================================================================
; COC3092 - Microprocessor Theory & Applications
; Assignment - II, Question 3
; Linear search on 'n' elements (x86-64, NASM, Intel syntax)
;
; Called from C as:  linear_search(int *arr, int n, int key)
;   - RDI = arr (pointer to the first element)
;   - ESI = n (element count), EDX = key (value to find)
;   - Returns in EAX: the index of the first element equal to key,
;     or -1 when no element equals key.
;   - Algorithm: check arr[0], then arr[1], then arr[2], ... in order.
;     Stop at the first match. This is "linear" because in the worst
;     case every element is checked once, so time grows linearly with n.
;
; Registers used:
;   R12  = arr (callee-saved)   R13D = n (callee-saved)
;   R14D = key (callee-saved)   R15D = i, the current index
;   EAX  = return value (and scratch for the element being compared)
; ============================================================================

        global  linear_search   ; make the routine visible to the C linker

        section .text
linear_search:
        push    rbp             ; save the caller's base pointer
        mov     rbp, rsp        ; set up our own stack frame
        push    r12             ; save R12 (arr pointer)
        push    r13             ; save R13 (n)
        push    r14             ; save R14 (key)
        push    r15             ; save R15 (i)

        mov     r12, rdi        ; R12 = arr, base address of the array
        mov     r13d, esi       ; R13D = n, number of elements
        mov     r14d, edx       ; R14D = key, the value to find
        xor     r15d, r15d      ; i = 0, start at the first element

.loop:                          ; ---- check arr[i] ----
        cmp     r15d, r13d      ; compare i with n
        jge     .not_found      ; if i >= n, the whole array was checked

        ; Load arr[i]. Each int is 4 bytes, so element i is at base + i*4.
        mov     eax, [r12 + r15*4]      ; EAX = arr[i]
        cmp     eax, r14d       ; compare arr[i] with key
        je      .found          ; if equal, this is the first match

        inc     r15d            ; i = i + 1 (move to the next element)
        jmp     .loop           ; ---- check the next element ----

.found:
        mov     eax, r15d       ; EAX = i, the index of the match
        jmp     .exit           ; return i to C

.not_found:
        mov     eax, -1         ; EAX = -1, the "not present" signal

.exit:
        pop     r15             ; restore R15 (reverse order of the pushes)
        pop     r14             ; restore R14
        pop     r13             ; restore R13
        pop     r12             ; restore R12
        pop     rbp             ; restore the caller's base pointer
        ret                     ; return to C (main), with the result in EAX

        section .note.GNU-stack noalloc noexec nowrite progbits
