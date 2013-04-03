#include <stdio.h>
#include <stddef.h>

extern int asmb(char *s, size_t n);

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
    char *s1 = " 1 3 5 7 9 B D F  23  67  AB  EF    4567    CDEF";
    printf("asmb_orig(s1, 16) = %d\n", asmb_orig(s, 16));
    printf("asmb(s1, 16) = %d\n", asmb(s, 16));

    printf("asmb_orig(s1, 0) = %d\n", asmb_orig(s, 0));
    printf("asmb(s1, 0) = %d\n", asmb(s, 0));

    printf("asmb_orig(s1, 1) = %d\n", asmb_orig(s, 1));
    printf("asmb(s1, 1) = %d\n", asmb(s, 1));

    printf("asmb_orig(s1, 8) = %d\n", asmb_orig(s, 8));
    printf("asmb(s1, 8) = %d\n", asmb(s, 8));

    printf("asmb_orig(s1, 15) = %d\n", asmb_orig(s, 15));
    printf("asmb(s1, 15) = %d\n", asmb(s, 15));

    printf("asmb_orig(s1, 16) = %d\n", asmb_orig(s, 16));
    printf("asmb(s1, 16) = %d\n", asmb(s, 16));

    printf("asmb_orig(s1, 17) = %d\n", asmb_orig(s, 17));
    printf("asmb(s1, 17) = %d\n", asmb(s, 17));

    printf("asmb_orig(s1, 24) = %d\n", asmb_orig(s, 24));
    printf("asmb(s1, 24) = %d\n", asmb(s, 24));

    printf("asmb_orig(s1, 31) = %d\n", asmb_orig(s, 31));
    printf("asmb(s1, 31) = %d\n", asmb(s, 31));
}

