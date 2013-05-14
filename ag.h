#ifndef AG_H
#define AG_H

enum PrimitiveType{
    PrimitiveUndefined,
    PrimitiveInt
};

/** 
 * VariableType 
 */
typedef struct _VariableType {
    /* 
     * The rank of the array. A value of 0 means the variable type is the 
     * primitive type.
     */ 
    int rank;

    /*
     * The underlying primitive type of the array.
     */
    enum PrimitiveType primitive;
} VariableType;

VariableType *newVariableType(int rank);
gboolean eqVariableType(VariableType *left, VariableType *right);
VariableType *downrankVariableType(VariableType *type);

/**
 * VariableDeclaration
 */
typedef struct _VariableDeclaration {
    char *name;
    VariableType *type;
} VariableDeclaration;

VariableDeclaration *newVariableDeclaration(char *name, VariableType *type);

/**
 * ScopeFrame
 */
typedef struct _ScopeFrame {
    int len;
    GSList *declarations;
} ScopeFrame;

ScopeFrame *newScopeFrame();
ScopeFrame *frameAddDeclaration(ScopeFrame *frame, VariableDeclaration *declaration);
void printScopeFrame(ScopeFrame* frame);

/**
 * ScopeChain
 */
typedef struct _ScopeChain {
    int len;
    GSList *frames;
} ScopeChain;
ScopeChain *newScopeChain();
ScopeChain *chainPushFrame(ScopeChain *chain, ScopeFrame *frame);
ScopeChain *chainAddDeclaration(ScopeChain *chain, VariableDeclaration *declaration);
void printScopeChain(ScopeChain* chain);
gboolean _debugScopeChain;
void debugScopeChain(char *label, ScopeChain *chain);

/**
 * Semantic checks
 */
void checkDuplicateParameters(char *function_identifier, ScopeFrame *parameters);
void checkIdentifierInScope(char *identifier, ScopeChain *scope);
void checkIsInteger(VariableType *type);
void checkIsArray(VariableType *type);
void checkSameType(VariableType *left, VariableType *right);

VariableDeclaration *findDeclarationInScope(char *identifier, ScopeChain *scope);
VariableType *findTypeInScope(char *identifier, ScopeChain *scope);



#endif
