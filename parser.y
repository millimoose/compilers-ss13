%{
  #include <stdlib.h>
  #include <stdio.h>
  #include <string.h>
  #include <glib.h>

  #include "ag.h"
  #include "status-codes.h"
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

@attributes { char *identifier; struct _ScopeFrame *parameters; } funcdef
@attributes { struct _ScopeFrame *parameters; } pars

@attributes { int rank; } array
@attributes { struct _VariableType *type; } type
@attributes { struct _VariableDeclaration *declaration; } vardef 

@attributes { struct _ScopeChain *in_chain; struct _ScopeChain *out_chain; } stats
@attributes { struct _ScopeChain *in_chain; struct _ScopeChain *out_chain; } stat

@traversal preorder stats
@traversal preorder funcdef

%%

// 0 or more funcdef
program : program funcdef ';'
        | 
        ;

funcdef : TIdentifier '(' pars ')' stats TEnd
          @{ 
            @i @funcdef.parameters@ = @pars.parameters@;
            @i @funcdef.identifier@ = @TIdentifier.name@;
            @i @stats.in_chain@ = chainPushFrame(newScopeChain(), @funcdef.parameters@);
            @stats printScopeChain(@stats.out_chain@);
            @funcdef checkDuplicateParameters(@funcdef.identifier@, @funcdef.parameters@);
          @}
        ;

// 0 or more vardef
pars : pars ',' vardef
       @{ @i @pars.0.parameters@ = frameAddDeclaration(@pars.1.parameters@, @vardef.declaration@); @}
     | vardef
       @{ @i @pars.parameters@ = frameAddDeclaration(newScopeFrame(), @vardef.declaration@); @} 
     |
       @{ @i @pars.parameters@ = newScopeFrame(); @}
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
        @{ 
          @i @stats.out_chain@ = chainPushFrame(@stats.in_chain@, newScopeFrame()); 
        @}
      ;

stat : TReturn expr
       @{ @i @stat.out_chain@ = @stat.in_chain@; @}
     | TIf bool TThen stats TEnd
       @{ 
         @i @stats.in_chain@ = @stat.in_chain@;
         @i @stat.out_chain@ = @stat.in_chain@;
         @stats printScopeChain(@stats.out_chain@);
       @}
     | TIf bool TThen stats TElse stats TEnd
       @{
         @i @stats.0.in_chain@ = @stat.in_chain@;
         @i @stats.1.in_chain@ = @stat.in_chain@;
         @i @stat.out_chain@ = @stat.in_chain@;
         @stats printScopeChain(@stats.0.out_chain@); printScopeChain(@stats.1.out_chain@);
       @}
     | TWhile bool TDo stats TEnd
       @{ 
         @i @stats.in_chain@ = @stat.in_chain@;
         @i @stat.out_chain@ = @stat.in_chain@;
         @stats printScopeChain(@stats.out_chain@);
       @}
     | TVar vardef TAssign expr
       @{ 
        @i @stat.out_chain@ = chainAddDeclaration(@stat.in_chain@, @vardef.declaration@);

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

funccall : TIdentifier '(' callpars ')' ':' type
         ;

callpars : _callpars
         |
         ;

_callpars : _callpars ',' expr
          | expr
          ;

%%

void yyerror(char *msg) {
    printf("%d: %s\n", 
        yylineno, msg);
    exit(StatusParserError);
}

int main(int nargs, char **args) {
    return yyparse();
}