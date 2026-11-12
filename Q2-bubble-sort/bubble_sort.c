/* ============================================================================
 * COC3092 - Microprocessor Theory & Applications
 * Assignment - II, Question 2
 * Bubble sort on 'n' elements (x86-64, NASM + GCC)
 *
 * Role of this file (C):
 *   - Takes n and the n array elements from the user.
 *   - Prints the array before sorting.
 *   - Hands the array to the assembly routine bubble_sort(), which sorts
 *     it in place (ascending order).
 *   - Prints the sorted array.
 *
 * Role of bubble_sort.asm:
 *   - The whole sort: repeated passes, comparing neighbours and swapping
 *     any pair that is out of order, until no swaps are needed in a pass
 *     range. After pass i, the largest of the unsorted part is at the end.
 *
 * Build (Linux, x86-64):
 *   nasm -f elf64 bubble_sort.asm -o bubble_sort.o
 *   gcc bubble_sort.c bubble_sort.o -o bubble_sort
 * Run:
 *   ./bubble_sort
 * ========================================================================== */

#include <stdio.h>      /* printf(), scanf() */
#include <stdlib.h>     /* malloc(), free() */

/* Assembly routine defined in bubble_sort.asm.
 * arr = pointer to the first element, n = number of elements. Sorts in place. */
extern void bubble_sort(int *arr, int n);

int main(void)
{
    int n;              /* number of elements */
    int *arr;           /* the array (allocated once n is known) */
    int i;              /* loop index for reading / printing */

    /* Read n, and reject anything that is not a positive count. */
    printf("Enter the number of elements (n): ");
    if (scanf("%d", &n) != 1 || n <= 0) {
        printf("Invalid input. Please enter a positive integer for n.\n");
        return 1;
    }

    /* Allocate exactly n ints. malloc() fails only if memory runs out. */
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

    /* Show the array as entered, then let assembly sort it. */
    printf("Before sorting: ");
    for (i = 0; i < n; i++)
        printf("%d ", arr[i]);
    printf("\n");

    bubble_sort(arr, n);    /* assembly sorts the array in place */

    /* Show the result. */
    printf("After sorting:  ");
    for (i = 0; i < n; i++)
        printf("%d ", arr[i]);
    printf("\n");

    free(arr);              /* give the allocated memory back */
    return 0;
}
