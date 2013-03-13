char *ss = "                ";

int asma_orig(char *s) {
    int c=0;

    for (int i=0; i<16; i++) {
        if (s[i]==ss[7]) {
            c++;
        }
    }

    return c;
}