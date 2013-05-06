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

GHashTable *newScope() {
  return g_hash_table_new(g_str_hash, g_str_equal);
}

GHashTable *addToScope(GHashTable *scope, struct VariableDeclaration *declaration) {
    g_hash_table_insert(scope, declaration->name, declaration);
    return scope;
}