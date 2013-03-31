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

int main(int argc, char **argv) {
    char *s = "    5678        ";
    printf("asmb_orig() = %d\n", asmb_orig(s, 16));
    printf("asmb() = %d\n", asmb(s, 16));
}

