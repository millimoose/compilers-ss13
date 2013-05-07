#ifndef AG_H
#define AG_H

enum PrimitiveType{
  PrimitiveUndefined,
  PrimitiveInt
};

struct VariableType {
  /* 
   * The rank of the array. A value of 0 means the variable type is the 
   * primitive type.
   */ 
  int rank;

  /*
   * The underlying primitive type of the array.
   */
  enum PrimitiveType primitive;
};

struct VariableType *newVariableType(int rank);

struct VariableDeclaration {
  char *name;
  struct VariableType *type;
};
struct VariableDeclaration *newVariableDeclaration(char *name, struct VariableType *type);

GSList *newScope();
GSList *scopePushDeclaration(GSList *scope, struct VariableDeclaration *variable);

GSList *newChain();
GSList *chainPushScope(GSList *chain, GSList *scope);

#endif
