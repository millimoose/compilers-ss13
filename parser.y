%{
    #include <stdlib.h>
    #include <stdio.h>

    int yylex(void); 
    void yyerror(char *); 
%}

// Keywords
%token TEnd TArray TOf TInt TReturn TIf TThen TElse TWhile TDo TVar TNot TOr TAssign
%token TDecimalLiteral THexLiteral TIdentifier

%start program

%locations
%defines
%error-verbose
%verbose

%%

program : program funcdef
        | // 0 or more funcdef
        ;

funcdef : TIdentifier '(' pars ')' stats TEnd
        ;

pars : pars ',' vardef
     | vardef; 
     | // 0 or more vardef
     ;

vardef : TIdentifier ':' type
       ;

type : array TInt
     ;

array : array TArray TOf
      | // 0 or more "array of"
      ;

stats : stats stat ';'
      | // 0 or more stat
      ;

stat : TReturn expr
     | TIf bool TThen stats TEnd
     | TIf bool TThen stats TElse stats TEnd
     | TWhile bool TDo stats TEnd
     | TVar vardef TAssign expr
     | lexpr TAssign expr
     | term
     ;

bool : bool TOr bterm
     | bterm
     ;

bterm : '(' bool ')'
      | TNot bterm
      | expr '<' expr
      | expr '#' expr
      ;

lexpr : TIdentifier
      | term '[' expr ']'
      ;

expr : expr '-' mexpr
     | expr '+' mexpr
     | mexpr
     ;

mexpr : mexpr '*' term
      | term
      ;

term : '(' expr ')'
     | term '[' expr ']'
     | TIdentifier
     | TDecimalLiteral
     | THexLiteral
     | funccall
     ;

funccall : TIdentifier '(' fcpars ')' ':' type
         ;

fcpars : fcpars ',' expr
       | expr
       |
       ;

%%

void yyerror(char *msg) {
    printf("%d:%d-%d.%d: %s\n", 
        yylloc.first_line, yylloc.first_column, 
        yylloc.last_line, yylloc.last_column, msg);
    exit(2);
}

int main(int nargs, char **args) {
    return yyparse();
}