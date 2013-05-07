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


#endif
