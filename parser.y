%{
  #include <stdlib.h>
  #include <stdio.h>
  #include <string.h>
  #include <glib.h>

  #include "ag.h"
%}

%union {}

%{
  extern int yylineno;
  int yylex();
  void yyerror(char *msg);
%}

///%error-verbose

// Keywords
%token TEnd TArray TOf TInt TReturn TIf TThen TElse TWhile TDo TVar TNot TOr TAssign
%token TDecimalLiteral THexLiteral TIdentifier

%start program

@attributes {int value;} TDecimalLiteral
@attributes {int value;} THexLiteral
@attributes {char *name;} TIdentifier

@attributes { GHashTable *variables; } funcdef
@attributes { GHashTable *variables; } pars

@attributes { int rank; } array;
@attributes { struct VariableType *type; } type;
@attributes { struct VariableDeclaration *declaration; } vardef 


%%

program : program funcdef ';'
        | // 0 or more funcdef
        ;

funcdef : TIdentifier '(' pars ')' stats TEnd
          @{ @i @funcdef.variables@ = @pars.variables@; @}
        ;

// 0 or more vardef
pars : pars ',' vardef
       @{ @i @pars.0.variables@ = addToScope(@pars.1.variables@, @vardef.declaration@); @}
     | vardef
       @{ @i @pars.variables@ = addToScope(newScope(), @vardef.declaration@); @} 
     |
       @{ @i @pars.variables@ = newScope(); @}
     ;

vardef : TIdentifier ':' type
         @{ @i @vardef.declaration@ = newVariableDeclaration(@TIdentifier.name@, @type.type@); @}
       ;

type : array TInt 
       @{ @i @type.type@ = newVariableType(@array.rank@); @}
     ;

// 0 or more "array of"
array : array TArray TOf 
        @{ @i @array.0.rank@ = @array.1.rank@ + 1; @}
      | 
        @{ @i @array.0.rank@ = 0; @}
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

expr : addexpr
     | subexpr
     | mulexpr
     | term
     ;

addexpr : addexpr '+' term
        | term '+' term
        ;

subexpr : subexpr '-' term
        | term '-' term
        ;

mulexpr : mulexpr '*' term
        | term '*' term
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

fcpars : fcpar
       |
       ;

fcpar : fcpar ',' expr
      | expr
      ;

%%

void yyerror(char *msg) {
    printf("%d: %s\n", 
        yylineno, msg);
    exit(2);
}

int main(int nargs, char **args) {
    return yyparse();
}