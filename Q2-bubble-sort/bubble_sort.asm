; ============================================================================
; COC3092 - Microprocessor Theory & Applications
; Assignment - II, Question 2
; Bubble sort on 'n' elements (x86-64, NASM, Intel syntax)
;
; Called from C as:  bubble_sort(int *arr, int n)
;   - RDI = arr (pointer to the first element), ESI = n (element count).
;   - Sorts the array in place, ascending order. Returns nothing.
;   - Algorithm: for i = 0 to n-2, run one pass over j = 0 to n-i-2;
;     if arr[j] > arr[j+1], swap them. After pass i, the largest of the
;     still-unsorted part has "bubbled" to position n-i-1, so the next
;     pass can stop one element earlier.
;
; Registers used (all callee-saved, so C's values survive the call):
;   R12  = arr (base address)   R13D = n
;   R14D = i (outer pass)       R15D = j (inner index)
;   EBX/ECX = the two neighbours being compared (EBX is callee-saved too)
; ============================================================================

        global  bubble_sort     ; make the routine visible to the C linker

        section .text
bubble_sort:
        push    rbp             ; save the caller's base pointer
        mov     rbp, rsp        ; set up our own stack frame
        push    rbx             ; save RBX (used for arr[j])
        push    r12             ; save R12 (arr pointer)
        push    r13             ; save R13 (n)
        push    r14             ; save R14 (i)
        push    r15             ; save R15 (j)

        mov     r12, rdi        ; R12 = arr, base address of the array
        mov     r13d, esi       ; R13D = n, number of elements
        xor     r14d, r14d      ; i = 0, first pass

.outer:                         ; ---- start of pass i ----
        mov     eax, r13d       ; EAX = n
        dec     eax             ; EAX = n - 1
        cmp     r14d, eax       ; compare i with n - 1
        jge     .done           ; if i >= n - 1, sorting is finished

        xor     r15d, r15d      ; j = 0, start of this pass

.inner:                         ; ---- compare arr[j] and arr[j+1] ----
        mov     eax, r13d       ; EAX = n
        sub     eax, r14d       ; EAX = n - i
        dec     eax             ; EAX = n - i - 1 (last j in this pass)
        cmp     r15d, eax       ; compare j with n - i - 1
        jge     .next_pass      ; if j >= limit, this pass is done

        ; Load the neighbouring pair. [R12 + R15*4] is arr[j] because
        ; each int is 4 bytes, so element j sits at base + j*4.
        mov     ebx, [r12 + r15*4]      ; EBX = arr[j]
        mov     ecx, [r12 + r15*4 + 4]  ; ECX = arr[j+1]
        cmp     ebx, ecx        ; compare arr[j] with arr[j+1]
        jle     .no_swap        ; if arr[j] <= arr[j+1], already in order

        ; Swap them: arr[j] = old arr[j+1], arr[j+1] = old arr[j].
        mov     [r12 + r15*4], ecx      ; arr[j]   = ECX (the smaller one)
        mov     [r12 + r15*4 + 4], ebx  ; arr[j+1] = EBX (the larger one)

.no_swap:
        inc     r15d            ; j = j + 1 (move to the next pair)
        jmp     .inner          ; ---- repeat for the next pair ----

.next_pass:
        inc     r14d            ; i = i + 1 (next pass, one fewer element)
        jmp     .outer          ; ---- start the next pass ----

.done:
        pop     r15             ; restore R15 (reverse order of the pushes)
        pop     r14             ; restore R14
        pop     r13             ; restore R13
        pop     r12             ; restore R12
        pop     rbx             ; restore RBX
        pop     rbp             ; restore the caller's base pointer
        ret                     ; return to C (main)

        section .note.GNU-stack noalloc noexec nowrite progbits
