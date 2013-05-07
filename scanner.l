%{

#include "parser.tab.h"

#include <stdlib.h>
#include <stdio.h>
#include <glib.h>

%}

%option warn yylineno noyywrap nodefault bison-bridge

%%

end         return TEnd;
array       return TArray;
of          return TOf;
int         return TInt;
return      return TReturn;
if          return TIf;
then        return TThen;
else        return TElse;
while       return TWhile;
do          return TDo;
var         return TVar;
not         return TNot;
or          return TOr;
":="        return TAssign;

";"     return ';';
"("     return '(';
")"     return ')';
","     return ',';
":"     return ':';
"<"     return '<';
"#"     return '#';
"["     return '[';
"]"     return ']'; 
"-"     return '-';
"+"     return '+';
"*"     return '*';

"$"[[:xdigit:]]+            return THexLiteral;         @{ @THexLiteral.value@ = strtol(yytext+1, NULL, 16); @}
[[:digit:]]+                return TDecimalLiteral;     @{ @TDecimalLiteral.value@ = strtol(yytext, NULL, 10); @}
[[:alpha:]][[:alnum:]]*     return TIdentifier;         @{ @TIdentifier.name@ = g_strdup(yytext); @}

"--".*       // skip comment
[[:space:]]+ // skip whitespace

. { 
    printf("%d: unexpected token %s\n", yylineno, yytext); 
    exit(1); 
}

%%