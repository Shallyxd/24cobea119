/* ============================================================================
 * COC3092 - Microprocessor Theory & Applications
 * Assignment - II, Question 4
 * Menu-driven string operations (x86 / x86-64, NASM + GCC)
 *
 * Role of this file (C):
 *   - Takes one string from the user. fgets() is used (not scanf("%s"))
 *     so the string may contain spaces, e.g. "naman" or "madam im adam".
 *   - Strips the trailing newline that fgets() keeps.
 *   - Hands the string to the assembly routine string_menu(), which
 *     shows the menu and performs every operation.
 *
 * Role of string_menu.asm:
 *   - The whole menu loop and all six operations:
 *       1. Display the string
 *       2. Find its length
 *       3. Reverse it (on a copy, so the original is not changed)
 *       4. Check whether it is a palindrome
 *       5. Search it for a given character
 *       6. Exit
 *
 * Build (Linux, x86-64):
 *   nasm -f elf64 string_menu.asm -o string_menu.o
 *   gcc string_menu.c string_menu.o -o string_menu
 * Run:
 *   ./string_menu
 * ========================================================================== */

#include <stdio.h>      /* printf(), fgets() */
#include <string.h>     /* strlen() - only to strip the newline in C */

#define MAX_LEN 255     /* longest string accepted (255 chars + '\0') */

/* Assembly routine defined in string_menu.asm. Takes the string in RDI. */
extern void string_menu(char *str);

int main(void)
{
    char str[MAX_LEN + 1];  /* room for 255 chars plus the '\0' terminator */
    size_t len;             /* length, used only to strip the newline */

    /* Read a whole line, spaces included. */
    printf("Enter a string (max %d characters): ", MAX_LEN);
    if (fgets(str, sizeof(str), stdin) == NULL) {
        printf("No input received.\n");
        return 1;
    }

    /* fgets() keeps the Enter key as '\n' at the end; remove it. */
    len = strlen(str);
    if (len > 0 && str[len - 1] == '\n')
        str[len - 1] = '\0';

    /* Hand the string to assembly; it runs the menu until the user exits. */
    string_menu(str);

    return 0;
}
