#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <glib.h>

#include "ag.h"
#include "status-codes.h"

VariableType *newVariableType(int rank) {
    VariableType *result = g_new(VariableType, 1);
    result->rank = rank;
    result->primitive = PrimitiveInt;
    return result;
}

static char *PrimitiveTypeNames[] = {
    "<undefined>", "int"
};  

char *stringFromType(VariableType *type) {
    GString *result = g_string_new("");
    for (int i = 0; i < type->rank; i++) {
      g_string_append(result, "array of ");
    }
    g_string_append(result, PrimitiveTypeNames[type->primitive]);
    return g_string_free(result, FALSE);
}

VariableDeclaration *newVariableDeclaration(char *name, VariableType *type) {
    char *type_s = stringFromType(type);
    g_message("newVariableDeclaration(name: %s, type: %s)", name, type_s);
    g_free(type_s);
    VariableDeclaration *result = g_new(VariableDeclaration, 1);
    result->name = name;
    result->type = type;
    return result;
}

char *stringFromDeclaration(VariableDeclaration *declaration) {
    GString *result = g_string_new("");
    char *type_s = stringFromType(declaration->type);
    g_string_printf(result, "%s : %s", declaration->name, type_s);
    g_free(type_s);
    return g_string_free(result, FALSE);
}

ScopeFrame *newScopeFrame() {
    ScopeFrame *result = g_new(ScopeFrame, 1);
    result->len = 0;
    result->declarations = NULL;
    return result;
}

ScopeFrame *frameAddDeclaration(ScopeFrame *frame, VariableDeclaration *declaration) {
    ScopeFrame *result = g_new(ScopeFrame, 1);
    result->len = frame->len+1;
    result->declarations = g_slist_prepend(frame->declarations, declaration);
    return result;
}

void printScopeFrame(ScopeFrame *scope) {
    for (GSList *it = scope->declarations; it != NULL; it = it->next) {
        VariableDeclaration *declaration = it->data;
        char *declaration_s = stringFromDeclaration(declaration);
        puts(declaration_s);
        g_free(declaration_s);
    }
}

ScopeChain *newScopeChain() {
    ScopeChain *result = g_new(ScopeChain, 1);
    result->len = 0;
    result->frames = NULL;
    return result;
}

ScopeChain *chainPushFrame(ScopeChain *chain, ScopeFrame *frame) {
    ScopeChain *result = g_new(ScopeChain, 1);
    result->len = chain->len+1;
    result->frames = g_slist_prepend(chain->frames, frame);

    return result;
}


ScopeChain *chainAddDeclaration(ScopeChain *chain, VariableDeclaration *declaration) {
    ScopeChain *result = g_new(ScopeChain, 1);
    ScopeFrame *top_frame = chain->frames->data;
    
    result->len = chain->len;  
    result->frames = g_slist_prepend(chain->frames->next, 
                                           frameAddDeclaration(top_frame, declaration));
    
    frameAddDeclaration(top_frame, declaration);
    return result;
}

void printScopeChain(ScopeChain *chain) {
    int i = 0;
    for (GSList *it = chain->frames; 
         it != NULL; 
         it = it->next, i++) {
        ScopeFrame *frame = it->data;

        printf("[ Scope %d ]\n", i);
        printScopeFrame(frame);
    }
    puts("");
}

void checkDuplicateParameters(char *identifier, ScopeFrame *parameters) {
    g_message("checkDuplicateParameters(identifier: %s)", identifier);
    GSList *declarations = g_slist_reverse(parameters->declarations);
    GHashTable *visited = g_hash_table_new(&g_str_hash, &g_str_equal);

    for (GSList *it = declarations; it != NULL; it = it->next) {
        VariableDeclaration *declaration = it->data;
        char *declaration_s = stringFromDeclaration(declaration);
        g_message("checkDuplicateParameters():\nvisiting parameter '%s'", declaration_s);
        g_free(declaration_s);
        VariableDeclaration *visited_declaration = g_hash_table_lookup(visited, declaration->name);

        if (visited_declaration == NULL) {
            g_hash_table_insert(visited, declaration->name, declaration);
        } else {
            g_critical("checkDuplicateParameters():\nduplicate parameters '%s' and '%s'", 
                       stringFromDeclaration(visited_declaration), 
                    stringFromDeclaration(declaration));
            exit(StatusSemanticError);
        }
    }

    g_hash_table_destroy(visited);
    g_slist_free(declarations);
}

gboolean isIdentifierInFrame(char *identifier, ScopeFrame *frame) {
    for (GSList *it = frame->declarations; it != NULL; it = it->next) {
        VariableDeclaration *declaration = it->data;
        if (g_strcmp0(identifier, declaration->name) == 0) {
            return TRUE;
        }
    }
    return FALSE;
}

gboolean isIdentifierInChain(char *identifier, ScopeChain *chain) {
    for (GSList *it = chain->frames; it != NULL; it = it->next) {
        ScopeFrame *frame = it->data;
        if (isIdentifierInFrame(identifier, frame)) {
            return TRUE;
        }
    }

    return FALSE;
}

void checkIdentifierInScope(char *identifier, ScopeChain *scope) {
    g_message("checkIdentifierInScope(identifier: %s)", identifier);
    printScopeChain(scope);
    if (!isIdentifierInChain(identifier, scope)) {
        g_critical("checkIdentifierInScope():\nidentifier not in scope: %s", identifier);
        exit(StatusSemanticError);
    }
}
