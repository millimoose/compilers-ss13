#include <stdio.h>
#include <stddef.h>

extern int asmb(char *s, size_t n);
extern int asmb_test(char *s, size_t n);

size_t asmb_orig(char *s, size_t n) {
    size_t c=0;
    size_t i;
  
    for (i=0; i<n; i++) {
        if (s[i]==' ') {
            c++;
        }
    }

    return c; 
}

// copy-paste after test string to make sure there's enough space available after the end.
char *guard = " 1 3 5 7 9 B D F";

int main(int argc, char **argv) {
    //          0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
    char *s = " 1 3 5 7 9 B D F  23  67  AB  EF    4567    CDEF";
    puts("===\n");
    printf("asmb_test(s, 1) = %d\n", asmb_test(s, 1));
    printf("asmb_test(s, 1) = %X\n", asmb_test(s, 1));
    puts("===\n\n");

    printf("asmb_orig(s, 16) = %d\n", asmb_orig(s, 16));
    printf("asmb(s, 16) = %d\n\n", asmb(s, 16));
    printf("asmb_orig(s, 17) = %d\n", asmb_orig(s, 17));
    printf("asmb(s, 17) = %d\n\n", asmb(s, 17));
    printf("asmb_orig(s, 18) = %d\n", asmb_orig(s, 18));
    printf("asmb(s, 18) = %d\n\n", asmb(s, 18));
    printf("asmb_orig(s, 19) = %d\n", asmb_orig(s, 19));
    printf("asmb(s, 19) = %d\n\n", asmb(s, 19));
    printf("asmb_orig(s, 20) = %d\n", asmb_orig(s, 20));
    printf("asmb(s, 20) = %d\n\n", asmb(s, 20));
    printf("asmb_orig(s, 21) = %d\n", asmb_orig(s, 21));
    printf("asmb(s, 21) = %d\n\n", asmb(s, 21));
    printf("asmb_orig(s, 22) = %d\n", asmb_orig(s, 22));
    printf("asmb(s, 22) = %d\n\n", asmb(s, 22));
    printf("asmb_orig(s, 23) = %d\n", asmb_orig(s, 23));
    printf("asmb(s, 23) = %d\n\n", asmb(s, 23));
    printf("asmb_orig(s, 24) = %d\n", asmb_orig(s, 24));
    printf("asmb(s, 24) = %d\n\n", asmb(s, 24));
}

