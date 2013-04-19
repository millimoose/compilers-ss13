%{

#include <stdlib.h>
#include <stdio.h>

void keyword() {
   printf("%s\n", yytext);
}

void hex_int() {
    int result = strtol(yytext+1, NULL, 16); // skip prefix
    printf("num %x\n", result);
}

void dec_int() {
    int result = strtol(yytext, NULL, 10);
    printf("num %x\n", result);
}

void identifier() {
    printf("id %s\n", yytext);
}

%}

%option main warn yylineno

%%

end         |
array       |
of          |
int         |
return      |
if          |
then        |
else        |
while       |
do          |
var         |
not         |
or          |

";"         |
"("         |
")"         |
","         |
":"         |
":="        |
"<"         |
"#"         |
"["         |
"]"         |
"-"         |
"+"         |
"*"         keyword();

"$"[[:xdigit:]]+          hex_int();
[[:digit:]]+            dec_int();
[[:alpha:]][[:alnum:]]* identifier();

"--".*       // skip comment
[[:space:]]+ // skip whitespace

.           { printf("ERROR: line %d\n", yylineno); exit(1); }

%%
