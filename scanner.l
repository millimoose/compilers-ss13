%{

#include <stdlib.h>
#include <stdio.h>
#include "parser.h"

%}

%option warn yylineno noyywrap nodefault bison-bridge bison-locations

%%

end     { return TEnd; }
array   { return TArray; }
of      { return TOf; }
int     { return TInt; }
return  { return TReturn; }
if      { return TIf; }
then    { return TThen; }
else    { return TElse; }
while   { return TWhile; }
do      { return TDo; }
var     { return TVar; }
not     { return TNot; }
or      { return TOr; }
":="    { return TAssign; }

";" |
"(" |
")" |
"," |
":" |
"<" |
"#" |
"[" |
"]" |
"-" |
"+" |
"*" { return *yytext; }

"$"[[:xdigit:]]+        { return THexLiteral; }
[[:digit:]]+            { return TDecimalLiteral; }
[[:alpha:]][[:alnum:]]* { return TIdentifier; }

"--".*       // skip comment
[[:space:]]+ // skip whitespace

. { 
    printf("%d.%d-%d.%d: %s\n", 
        yylloc->first_line, yylloc->first_column,
        yylloc->last_line, yylloc->last_column, yytext); 
    exit(1); 
}

%%