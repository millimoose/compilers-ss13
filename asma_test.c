#include <stdio.h>
extern int asma(char *s);

int asma_orig(char *s) {
    int c=0;

    for (int i=0; i<16; i++) {
        if (s[i]==' ') {
            c++;
        }
    }

    return c;
}

int main(int argc, char **argv) {
    char *s = "    5678        ";
    printf("asma_orig() = %d\n", asma_orig(s));
    printf("asma() = %d\n", asma(s));
}

