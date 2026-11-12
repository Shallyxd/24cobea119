/* ============================================================================
 * COC3092 - Microprocessor Theory & Applications
 * Assignment - II, Question 3
 * Linear search on 'n' elements (x86-64, NASM + GCC)
 *
 * Role of this file (C):
 *   - Takes n, the n array elements, and the value to find (key) from user.
 *   - Hands them to the assembly routine linear_search(), which scans the
 *     array from the first element onwards and returns the index of the
 *     first match, or -1 when the key is not present.
 *   - Prints the result in human form (position is index + 1).
 *
 * Role of linear_search.asm:
 *   - The whole scan: compare arr[i] with key for i = 0, 1, 2, ...;
 *     stop at the first match (return i) or at the end (return -1).
 *
 * Build (Linux, x86-64):
 *   nasm -f elf64 linear_search.asm -o linear_search.o
 *   gcc linear_search.c linear_search.o -o linear_search
 * Run:
 *   ./linear_search
 * ========================================================================== */

#include <stdio.h>      /* printf(), scanf() */
#include <stdlib.h>     /* malloc(), free() */

/* Assembly routine defined in linear_search.asm.
 * Returns the index of the first match, or -1 if key is not in the array. */
extern int linear_search(int *arr, int n, int key);

int main(void)
{
    int n;              /* number of elements */
    int *arr;           /* the array (allocated once n is known) */
    int key;            /* the value to search for */
    int index;          /* result from assembly: index, or -1 */
    int i;              /* loop index for reading / printing */

    /* Read n, and reject anything that is not a positive count. */
    printf("Enter the number of elements (n): ");
    if (scanf("%d", &n) != 1 || n <= 0) {
        printf("Invalid input. Please enter a positive integer for n.\n");
        return 1;
    }

    /* Allocate exactly n ints. */
    arr = malloc(n * sizeof(int));
    if (arr == NULL) {
        printf("Memory allocation failed.\n");
        return 1;
    }

    /* Read the n elements from the user. */
    printf("Enter %d element(s):\n", n);
    for (i = 0; i < n; i++) {
        printf("  element [%d]: ", i);
        if (scanf("%d", &arr[i]) != 1) {
            printf("Invalid input. Please enter integers only.\n");
            free(arr);
            return 1;
        }
    }

    /* Read the value to find. */
    printf("Enter the element to search for: ");
    if (scanf("%d", &key) != 1) {
        printf("Invalid input. Please enter an integer.\n");
        free(arr);
        return 1;
    }

    /* Show the array, then let assembly search it. */
    printf("Array: ");
    for (i = 0; i < n; i++)
        printf("%d ", arr[i]);
    printf("\n");

    index = linear_search(arr, n, key);    /* assembly does the scan */

    /* Report the result. Position = index + 1, because users count from 1. */
    if (index == -1)
        printf("%d is not present in the array.\n", key);
    else
        printf("%d is present at index %d (position %d).\n",
               key, index, index + 1);

    free(arr);              /* give the allocated memory back */
    return 0;
}
