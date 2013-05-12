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

/*

  enum _StatementType {
    StatementReturn,
    StatementIf
    StatementIfElse,
    StatementWhile,
    StatementNewVar,
    StatementAssign,
    StatementTerm
  };
  typedef enum _StatementType StatementType;

  static char *StatementTypeNames[] = {
    "return",
    "if",
    "if/else",
    "while",
    "variable",
    "assignment",
    "term"
  }

*/
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

@attributes {struct _ScopeChain *scope; } expr
@attributes {struct _ScopeChain *scope; } bool
@attributes {struct _ScopeChain *scope; } bterm
@attributes {struct _ScopeChain *scope; } term
@attributes {struct _ScopeChain *scope; } lexpr
@attributes {struct _ScopeChain *scope; } addexpr
@attributes {struct _ScopeChain *scope; } mulexpr
@attributes {struct _ScopeChain *scope; } subexpr
@attributes {struct _ScopeChain *scope; } funccall
@attributes {struct _ScopeChain *scope; } callpars
@attributes {struct _ScopeChain *scope; } _callpars
@attributes {struct _ScopeChain *scope; } fstats
@attributes {char *identifier; struct _ScopeChain *scope; } termid

// Prints the variables in scope for debugging
@traversal preorder stats
// semantic checks of function definitions
// (duplicate parameters)
@traversal preorder funcdef
// checks if an identifier is in scope
@traversal preorder termid

%%

// 0 or more funcdef
program : program funcdef ';'
        | 
        ;

funcdef : TIdentifier '(' pars ')' fstats TEnd
          @{ 
            @i @funcdef.parameters@ = @pars.parameters@;
            @i @funcdef.identifier@ = @TIdentifier.name@;
            @i @fstats.scope@ = chainPushFrame(newScopeChain(), @pars.parameters@);
            
            @funcdef checkDuplicateParameters(@funcdef.identifier@, @funcdef.parameters@);
            @stats puts("FUNCDEF.PARS"); printScopeFrame(@pars.parameters@);
          @}  
        ;

fstats  : stats
          @{
            @i @stats.in_chain@ = @fstats.scope@;
            
            @stats puts("FSTATS\n"); printScopeChain(@stats.in_chain@);
          @}
        ;

// 0 or more vardef
pars  : pars ',' vardef
        @{ 
          @i @pars.0.parameters@ = frameAddDeclaration(@pars.1.parameters@, @vardef.declaration@); 
        @}
      | vardef
        @{ 
          @i @pars.parameters@ = frameAddDeclaration(newScopeFrame(), @vardef.declaration@); 
        @} 
      |
        @{
          @i @pars.parameters@ = newScopeFrame(); 
        @}
      ;

vardef  : TIdentifier ':' type
          @{ 
            @i @vardef.declaration@ = newVariableDeclaration(@TIdentifier.name@, @type.type@); 
          @}
        ;

type  : array TInt 
        @{ 
          @i @type.type@ = newVariableType(@array.rank@); 
        @}
      ;

// 0 or more "array of"
array : array TArray TOf 
        @{ 
          @i @array.0.rank@ = @array.1.rank@ + 1; 
        @}
      | 
        @{ 
          @i @array.rank@ = 0; 
        @}
      ;

// 0 or more stat
stats : stats stat ';'
        @{ 
          @i @stats.1.in_chain@ = @stats.0.in_chain@;
          @i @stat.in_chain@ = @stats.1.out_chain@;
          @i @stats.0.out_chain@ = @stat.out_chain@;

          @stats  puts("STATS.leftin"); printScopeChain(@stats.1.in_chain@);
                  puts("STATS.rightin"); printScopeChain(@stat.in_chain@);
                  puts("STATS.out"); printScopeChain(@stats.0.out_chain@);
        @}
      | 
        @{ 
          @i @stats.out_chain@ = chainPushFrame(@stats.in_chain@, newScopeFrame()); 

          @stats puts("STATS(EPSILON).in"); printScopeChain(@stats.out_chain@);
        @}

      ;

stat  : TReturn expr
        @{ 
          @i @stat.out_chain@ = @stat.in_chain@; 
          @i @expr.scope@ = @stat.in_chain@;

          @stats puts("STAT(return)"); printScopeChain(@stat.in_chain@);
        @}
      | TIf bool TThen stats TEnd
        @{ 
          @i @stat.out_chain@ = @stat.in_chain@;
          @i @stats.in_chain@ = @stat.in_chain@;
          @i @bool.scope@ = @stat.in_chain@;

          @stats puts("STAT(if)"); printScopeChain(@stat.in_chain@);
        @}
      | TIf bool TThen stats TElse stats TEnd
        @{
          @i @stat.out_chain@ = @stat.in_chain@;
          @i @stats.0.in_chain@ = @stat.in_chain@;
          @i @stats.1.in_chain@ = @stat.in_chain@;
          @i @bool.scope@ = @stat.in_chain@;

          @stats puts("STAT(if/else)"); printScopeChain(@stat.in_chain@);
        @}
      | TWhile bool TDo stats TEnd
        @{ 
          @i @stat.out_chain@ = @stat.in_chain@;
          @i @stats.in_chain@ = @stat.in_chain@;
          @i @bool.scope@ = @stat.in_chain@;

          @stats puts("STAT(while)"); printScopeChain(@stat.in_chain@);
        @}
      | TVar vardef TAssign expr
        @{ 
          @i @stat.out_chain@ = chainAddDeclaration(@stat.in_chain@, @vardef.declaration@);
          @i @expr.scope@ = @stat.in_chain@;  

          @stats  puts("STAT(var).in");
                  printScopeChain(@stat.in_chain@);
                  puts("STAT(var).out");
                  printScopeChain(@stat.out_chain@);
        @}
      | lexpr TAssign expr
        @{ 
          @i @stat.out_chain@ = @stat.in_chain@;
          @i @expr.scope@ = @stat.in_chain@; 
          @i @lexpr.scope@ = @stat.in_chain@; 

          @stats puts("STAT(assign)"); printScopeChain(@stat.in_chain@);
        @}
      | term
        @{ 
          @i @stat.out_chain@ = @stat.in_chain@; 
          @i @term.scope@ = @stat.in_chain@;

          @stats puts("STAT(term)"); printScopeChain(@stat.in_chain@);
        @}
      ;

bool  : bool TOr bterm
        @{ 
          @i @bool.1.scope@ = @bool.0.scope@;
          @i @bterm.scope@ = @bool.0.scope@;
        @}
      | bterm
        @{
          @i @bterm.scope@ = @bool.scope@;
        @}
      ;

bterm : '(' bool ')'
        @{
          @i @bool.scope@ = @bterm.scope@;
        @}
      | TNot bterm
        @{
          @i @bterm.1.scope@ = @bterm.0.scope@;
        @}
      | expr '<' expr
        @{
          @i @expr.0.scope@ = @bterm.scope@;
          @i @expr.1.scope@ = @bterm.scope@;
        @}
      | expr '#' expr
        @{
          @i @expr.0.scope@ = @bterm.scope@;
          @i @expr.1.scope@ = @bterm.scope@;
        @}
      ;

lexpr : TIdentifier
      | term '[' expr ']'
        @{
          @i @term.scope@ = @lexpr.scope@;
          @i @expr.scope@ = @lexpr.scope@;
        @}
      ;

expr  : addexpr
        @{
          @i @addexpr.scope@ = @expr.scope@;
          @stats puts("EXPR(addexpr)"); printScopeChain(@expr.scope@);
        @}
      | subexpr
        @{
          @i @subexpr.scope@ = @expr.scope@;
          @stats puts("EXPR(subexpr)"); printScopeChain(@expr.scope@);
        @}
      | mulexpr
        @{
          @i @mulexpr.scope@ = @expr.scope@;
          @stats puts("EXPR(mulexpr)"); printScopeChain(@expr.scope@);
        @}
      | term
        @{
          @i @term.scope@ = @expr.scope@;
          @stats puts("EXPR(term)"); printScopeChain(@expr.scope@);
        @}
      ;

addexpr : addexpr '+' term
          @{
            @i @addexpr.1.scope@ = @addexpr.0.scope@;
            @i @term.scope@ = @addexpr.0.scope@;
          @}
        | term '+' term
          @{
            @i @term.0.scope@ = @addexpr.scope@;
            @i @term.1.scope@ = @addexpr.scope@;
          @}
        ;

subexpr : subexpr '-' term
          @{
            @i @subexpr.1.scope@ = @subexpr.0.scope@;
            @i @term.scope@ = @subexpr.0.scope@;
          @}
        | term '-' term
          @{
            @i @term.0.scope@ = @subexpr.scope@;
            @i @term.1.scope@ = @subexpr.scope@;
          @}
        ;

mulexpr : mulexpr '*' term
          @{
            @i @mulexpr.1.scope@ = @mulexpr.0.scope@;
            @i @term.scope@ = @mulexpr.0.scope@;
          @}
        | term '*' term
          @{
            @i @term.0.scope@ = @mulexpr.scope@;
            @i @term.1.scope@ = @mulexpr.scope@;
          @}
        ;

term  : '(' expr ')'
        @{
          @i @expr.scope@ = @term.scope@;
          @stats puts("TERM(parens)"); printScopeChain(@term.scope@);
        @}
      | term '[' expr ']'
        @{
          @i @term.1.scope@ = @term.0.scope@;
          @i @expr.scope@ = @term.scope@;
          @stats puts("TERM(index)"); printScopeChain(@term.0.scope@);
        @}
      | termid
        @{
          @i @termid.scope@ = @term.scope@;
          @stats puts("TERM(termid)"); printScopeChain(@term.scope@);
        @}
      | TDecimalLiteral
        @{
          @stats puts("TERM(decimal)"); printScopeChain(@term.scope@);
        @}
      | THexLiteral
        @{
          @stats puts("TERM(hex)"); printScopeChain(@term.scope@);
        @}
      | funccall
        @{
          @i @funccall.scope@ = @term.scope@;
          @stats puts("TERM(funccall)"); printScopeChain(@term.scope@);
        @}
      ;

termid  : TIdentifier
          @{
            @i @termid.identifier@ = @TIdentifier.name@;
            @stats puts("TERMID"); printScopeChain(@termid.scope@);
            //@termid checkIdentifierInScope(@termid.identifier@, @termid.scope@);
          @}
        ;

funccall  : TIdentifier '(' callpars ')' ':' type
            @{
              @i @callpars.scope@ = @funccall.scope@;
            @}
          ;

callpars  : _callpars
            @{
              @i @_callpars.scope@ = @callpars.scope@;
            @}
          |
          ;

_callpars : _callpars ',' expr
            @{
              @i @_callpars.1.scope@ = @_callpars.0.scope@;
              @i @expr.scope@ = @_callpars.0.scope@;
            @}
          | expr
            @{
              @i @expr.scope@ = @_callpars.scope@;
            @}
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