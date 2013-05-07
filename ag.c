#include <stdlib.h>

#include <glib.h>

#include "ag.h"

struct VariableType *newVariableType(int rank) {
  struct VariableType *result = malloc(sizeof(struct VariableType));
  result->rank = rank;
  result->primitive = PrimitiveInt;
  return result;
}

struct VariableDeclaration *newVariableDeclaration(char *name, struct VariableType *type) {
  struct VariableDeclaration *result = malloc(sizeof(struct VariableDeclaration));
  result->name = name;
  result->type = type;
  return result;
}

GSList *newScope() {
    return NULL;
}
GSList *scopePushDeclaration(GSList *scope, struct VariableDeclaration *declaration) {
    return g_slist_prepend(scope, declaration);
}

GSList *newChain() {
    return NULL;
}
GSList *chainPushScope(GSList *chain, GSList *scope) {
    return g_slist_prepend(chain, scope);
}