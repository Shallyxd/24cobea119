/* ============================================================================
 * COC3092 - Microprocessor Theory & Applications
 * Assignment - II, Question 1
 * Fibonacci series - 'n' terms (x86 / x86-64, NASM + GCC)
 *
 * Role of this file (C):
 *   - Takes 'n' from the user.
 *   - Validates it (n must be > 0).
 *   - Hands 'n' to the assembly routine fibonacci(), which prints the series.
 *
 * Role of fibonacci.asm:
 *   - Holds the series logic: a = 0, b = 1, next = a + b, then shift.
 *   - Prints every term with printf() from the C library.
 *
 * Build (Linux, x86-64):
 *   nasm -f elf64 fibonacci.asm -o fibonacci.o
 *   gcc fibonacci.c fibonacci.o -o fibonacci
 * Run:
 *   ./fibonacci
 * ========================================================================== */

#include <stdio.h>      /* printf(), scanf() */

/* Assembly routine defined in fibonacci.asm. Takes n in EDI, returns void. */
extern void fibonacci(int n);

int main(void)
{
    int n;              /* number of terms the user wants */

    /* Ask the user for n. */
    printf("Enter the number of terms (n): ");
    if (scanf("%d", &n) != 1) {
        printf("Invalid input. Please enter an integer.\n");
        return 1;
    }

    /* n = 0 or negative has no Fibonacci terms to print. */
    if (n <= 0) {
        printf("Please enter a positive integer.\n");
        return 1;
    }

    /* Hand the work to assembly; it prints the series. */
    printf("Fibonacci series (%d terms): ", n);
    fibonacci(n);

    return 0;
}
