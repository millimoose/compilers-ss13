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

@attributes { GSList *variables; } funcdef
@attributes { GSList *variables; } pars

@attributes { int rank; } array
@attributes { struct VariableType *type; } type
@attributes { struct VariableDeclaration *declaration; } vardef 

@attributes { GSList *in_chain; GSList *out_chain; } stats
@attributes { GSList *in_chain; GSList *out_chain; } stat

%%

// 0 or more funcdef
program : program funcdef ';'
        | 
        ;

funcdef : TIdentifier '(' pars ')' stats TEnd
          @{ 
            @i @funcdef.variables@ = @pars.variables@;
            @i @stats.in_chain@ = chainPushScope(newScope(), chainPushScope(newChain(), @funcdef.variables@)); 
          @}
        ;

// 0 or more vardef
pars : pars ',' vardef
       @{ @i @pars.0.variables@ = scopePushDeclaration(@pars.1.variables@, @vardef.declaration@); @}
     | vardef
       @{ @i @pars.variables@ = scopePushDeclaration(newScope(), @vardef.declaration@); @} 
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
        @{ @i @array.rank@ = 0; @}
      ;

// 0 or more stat
stats : stats stat ';'
        @{ 
           @i @stats.1.in_chain@ = @stats.0.in_chain@;
           @i @stat.in_chain@ = @stats.1.out_chain@;
           @i @stats.0.out_chain@ = @stat.out_chain@;
        @}
      | 
        @{ @i @stats.out_chain@ = @stats.in_chain@; @}
      ;

stat : TReturn expr
       @{ @i @stat.out_chain@ = @stat.in_chain@; @}
     | TIf bool TThen stats TEnd
       @{ 
         @i @stats.in_chain@ = chainPushScope(newScope(), @stat.in_chain@);
         @i @stat.out_chain@ = @stat.in_chain@;
       @}
     | TIf bool TThen stats TElse stats TEnd
       @{
         @i @stats.0.in_chain@ = chainPushScope(newScope(), @stat.in_chain@);
         @i @stats.1.in_chain@ = chainPushScope(newScope(), @stat.in_chain@);
         @i @stat.out_chain@ = @stat.in_chain@;
       @}
     | TWhile bool TDo stats TEnd
       @{ 
         @i @stats.in_chain@ = chainPushScope(newScope(), @stat.in_chain@);
         @i @stat.out_chain@ = @stat.in_chain@;
       @}
     | TVar vardef TAssign expr
       @{ 
        @i @stat.out_chain@ = chainPushScope(@stat.in_chain@->next, 
                                             scopePushDeclaration(@stat.in_chain@->data,
                                                                  @vardef.declaration@));

       @}
     | lexpr TAssign expr
       @{ @i @stat.out_chain@ = @stat.in_chain@; @}
     | term
       @{ @i @stat.out_chain@ = @stat.in_chain@; @}
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