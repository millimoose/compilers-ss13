%{
  #include <stdlib.h>
  #include <stdio.h>
  #include <string.h>
  #include <glib.h>

  #include "ag.h"
  #include "status-codes.h"

  // suppress warnings because of bad Ox output
  #pragma GCC diagnostic ignored "-Wformat"
  #pragma GCC diagnostic ignored "-Wformat-security"
  #pragma GCC diagnostic ignored "-Wdangling-else"
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
  
  gboolean _debugScopeChain = FALSE;
%}

///%error-verbose

// Keywords
%token TEnd TArray TOf TInt TReturn TIf TThen TElse TWhile TDo TVar TNot TOr TAssign
%token TDecimalLiteral THexLiteral TIdentifier

%start program

@attributes {int value;} TDecimalLiteral THexLiteral
@attributes {char *name;} TIdentifier

@attributes { char *identifier; struct _ScopeFrame *parameters; } funcdef
@attributes { struct _ScopeFrame *parameters; } pars

@attributes { int rank; } array
@attributes { struct _VariableType *type; } type
@attributes { struct _VariableDeclaration *declaration; } vardef 

@attributes { struct _ScopeChain *in_chain; struct _ScopeChain *out_chain; } stats stat

@attributes {struct _ScopeChain *scope; } bool bterm callpars _callpars fstats
@attributes {struct _ScopeChain *scope; struct _VariableType *type; } term lexpr expr addexpr mulexpr subexpr funccall
@attributes {char *identifier; struct _ScopeChain *scope; struct _VariableType *type; } termid

// Prints the variables in scope for debugging
@traversal inorder stats
// semantic checks of function definitions
// (duplicate parameters)
@traversal preorder funcdef
// checks if an identifier is in scope
@traversal postorder termid

@traversal postorder typecheck

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
            //@stats puts("FUNCDEF.PARS"); printScopeFrame(@pars.parameters@);
          @}  
        ;

fstats  : stats
          @{
            @i @stats.in_chain@ = @fstats.scope@;
            
            @stats debugScopeChain("FSTATS\n", @stats.in_chain@);
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

          @stats  debugScopeChain("STATS.leftin", @stats.1.in_chain@);
                  debugScopeChain("STATS.rightin", @stat.in_chain@);
                  debugScopeChain("STATS.out", @stats.0.out_chain@);
        @}
      | 
        @{ 
          @i @stats.out_chain@ = chainPushFrame(@stats.in_chain@, newScopeFrame()); 

          @stats debugScopeChain("STATS(EPSILON).in", @stats.out_chain@);
        @}

      ;

stat  : TReturn expr
        @{ 
          @i @stat.out_chain@ = @stat.in_chain@; 
          @i @expr.scope@ = @stat.in_chain@;

          @stats debugScopeChain("STAT(return)", @stat.in_chain@);
        @}
      | TIf bool TThen stats TEnd
        @{ 
          @i @stat.out_chain@ = @stat.in_chain@;
          @i @stats.in_chain@ = @stat.in_chain@;
          @i @bool.scope@ = @stat.in_chain@;

          @stats debugScopeChain("STAT(if)", @stat.in_chain@);
        @}
      | TIf bool TThen stats TElse stats TEnd
        @{
          @i @stat.out_chain@ = @stat.in_chain@;
          @i @stats.0.in_chain@ = @stat.in_chain@;
          @i @stats.1.in_chain@ = @stat.in_chain@;
          @i @bool.scope@ = @stat.in_chain@;

          @stats debugScopeChain("STAT(if/else)", @stat.in_chain@);
        @}
      | TWhile bool TDo stats TEnd
        @{ 
          @i @stat.out_chain@ = @stat.in_chain@;
          @i @stats.in_chain@ = @stat.in_chain@;
          @i @bool.scope@ = @stat.in_chain@;

          @stats debugScopeChain("STAT(while)", @stat.in_chain@);
        @}
      | TVar vardef TAssign expr
        @{ 
          @i @stat.out_chain@ = chainAddDeclaration(@stat.in_chain@, @vardef.declaration@);
          @i @expr.scope@ = @stat.in_chain@;  

          @stats  debugScopeChain("STAT(var).in", @stat.in_chain@);
                  debugScopeChain("STAT(var).out", @stat.out_chain@);
          @typecheck checkSameType(@vardef.declaration@->type, @expr.type@);

        @}
      | lexpr TAssign expr
        @{ 
          @i @stat.out_chain@ = @stat.in_chain@;
          @i @expr.scope@ = @stat.in_chain@; 
          @i @lexpr.scope@ = @stat.in_chain@; 

          @stats debugScopeChain("STAT(assign)", @stat.in_chain@);
          @typecheck checkSameType(@lexpr.type@, @expr.type@);
        @}
      | term
        @{ 
          @i @stat.out_chain@ = @stat.in_chain@; 
          @i @term.scope@ = @stat.in_chain@;

          @stats debugScopeChain("STAT(term)", @stat.in_chain@);
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
          @typecheck checkIsInteger(@expr.0.type@);
          @typecheck checkIsInteger(@expr.1.type@);
        @}
      | expr '#' expr
        @{
          @i @expr.0.scope@ = @bterm.scope@;
          @i @expr.1.scope@ = @bterm.scope@;
          @typecheck checkIsInteger(@expr.0.type@);
          @typecheck checkIsInteger(@expr.1.type@);
        @}
      ;

lexpr : TIdentifier
        @{
          @i @lexpr.type@ = findTypeInScope(@TIdentifier.name@, @lexpr.scope@);
        @}
      | term '[' expr ']'
        @{
          @i @term.scope@ = @lexpr.scope@;
          @i @expr.scope@ = @lexpr.scope@;
          @i @lexpr.type@ = downrankVariableType(@term.type@);
          @typecheck checkIsArray(@term.type@);
          @typecheck checkIsInteger(@expr.type@);
        @}
      ;

expr  : addexpr
        @{
          @i @addexpr.scope@ = @expr.scope@;
          @stats debugScopeChain("EXPR(addexpr)", @expr.scope@);
          @i @expr.type@ = @addexpr.type@;
        @}
      | subexpr
        @{
          @i @subexpr.scope@ = @expr.scope@;
          @stats debugScopeChain("EXPR(subexpr)", @expr.scope@);
          @i @expr.type@ = @subexpr.type@;
        @}
      | mulexpr
        @{
          @i @mulexpr.scope@ = @expr.scope@;
          @stats debugScopeChain("EXPR(mulexpr)", @expr.scope@);
          @i @expr.type@ = @mulexpr.type@;
        @}
      | term
        @{
          @i @term.scope@ = @expr.scope@;
          @stats debugScopeChain("EXPR(term)", @expr.scope@);
          @i @expr.type@ = @term.type@;
        @}
      ;

addexpr : addexpr '+' term
          @{
            @i @addexpr.1.scope@ = @addexpr.0.scope@;
            @i @term.scope@ = @addexpr.0.scope@;
            @i @addexpr.type@ = newVariableType(0);
            @typecheck checkIsInteger(@term.type@);
          @}
        | term '+' term
          @{
            @i @term.0.scope@ = @addexpr.scope@;
            @i @term.1.scope@ = @addexpr.scope@;
            @i @addexpr.type@ = newVariableType(0);
            @typecheck checkIsInteger(@term.0.type@);
            @typecheck checkIsInteger(@term.1.type@);
          @}
        ;

subexpr : subexpr '-' term
          @{
            @i @subexpr.1.scope@ = @subexpr.0.scope@;
            @i @term.scope@ = @subexpr.0.scope@;
            @i @subexpr.type@ = newVariableType(0);
            @typecheck checkIsInteger(@term.type@);
          @}
        | term '-' term
          @{
            @i @term.0.scope@ = @subexpr.scope@;
            @i @term.1.scope@ = @subexpr.scope@;
            @i @subexpr.type@ = newVariableType(0);
            @typecheck checkIsInteger(@term.0.type@);
            @typecheck checkIsInteger(@term.1.type@);
          @}
        ;

mulexpr : mulexpr '*' term
          @{
            @i @mulexpr.1.scope@ = @mulexpr.0.scope@;
            @i @term.scope@ = @mulexpr.0.scope@;
            @i @mulexpr.type@ = newVariableType(0);
            @typecheck checkIsInteger(@term.type@);
          @}
        | term '*' term
          @{
            @i @term.0.scope@ = @mulexpr.scope@;
            @i @term.1.scope@ = @mulexpr.scope@;
            @i @mulexpr.type@ = newVariableType(0);
            @typecheck checkIsInteger(@term.0.type@);
            @typecheck checkIsInteger(@term.1.type@);
          @}
        ;

term  : '(' expr ')'
        @{
          @i @expr.scope@ = @term.scope@;
          @stats debugScopeChain("TERM(parens)", @term.scope@);
          @i @term.type@ = @expr.type@;
        @}
      | term '[' expr ']'
        @{
          @i @term.1.scope@ = @term.0.scope@;
          @i @expr.scope@ = @term.scope@;
          @stats debugScopeChain("TERM(index)", @term.0.scope@);
          @i @term.0.type@ = downrankVariableType(@term.1.type@);
          @typecheck checkIsArray(@term.1.type@);
          @typecheck checkIsInteger(@expr.type@);
        @}
      | termid
        @{
          @i @termid.scope@ = @term.scope@;
          @stats debugScopeChain("TERM(termid)", @term.scope@);
          @i @term.type@ = @termid.type@;
        @}
      | TDecimalLiteral
        @{
          @stats debugScopeChain("TERM(decimal)", @term.scope@);
          @i @term.type@ = newVariableType(0);
        @}
      | THexLiteral
        @{
          @stats debugScopeChain("TERM(hex)", @term.scope@);
          @i @term.type@ = newVariableType(0);
        @}
      | funccall
        @{
          @i @funccall.scope@ = @term.scope@;
          @stats debugScopeChain("TERM(funccall)", @term.scope@);
          @i @term.type@ = @funccall.type@;
        @}
      ;

termid  : TIdentifier
          @{
            @i @termid.identifier@ = @TIdentifier.name@;
            @stats debugScopeChain("TERMID", @termid.scope@);
            @termid checkIdentifierInScope(@termid.identifier@, @termid.scope@);
            @i @termid.type@ = findTypeInScope(@termid.identifier@, @termid.scope@);
          @}
        ;

funccall  : TIdentifier '(' callpars ')' ':' type
            @{
              @i @callpars.scope@ = @funccall.scope@;
              @i @funccall.type@ = @type.type@;
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