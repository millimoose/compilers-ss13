int asma_orig(char *s) {
    int c=0;

    for (int i=0; i<16; i++) {
        if (s[i]==' ') {
            c++;
        }
    }

    return c;
}