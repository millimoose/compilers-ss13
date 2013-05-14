#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <glib.h>

#include "ag.h"
#include "status-codes.h"

GHashTable *_TypeCache = NULL;

GHashTable *TypeCache(void) {
    if (_TypeCache == NULL) {
        _TypeCache = g_hash_table_new(&g_direct_hash, &g_direct_equal);
    }
    return _TypeCache;
}

VariableType *newVariableType(int rank) {
    if (rank < 0) {
        g_warning("newVariableType(): creating variable with negative rank %d", rank);
    }

    VariableType *result = g_hash_table_lookup(TypeCache(), GINT_TO_POINTER(rank));
    if (result != NULL) {
        g_message("newVariableType(): returning cached type");
        return result;
    }

    result = g_new(VariableType, 1);
    result->rank = rank;
    result->primitive = PrimitiveInt;

    g_hash_table_insert(TypeCache(), GINT_TO_POINTER(rank), result);
    return result;
}

gboolean eqVariableType(VariableType *left, VariableType *right) {
    // HACK
    return left->rank == right->rank;
}

VariableType *downrankVariableType(VariableType *type) {
    if (type == NULL) {
        g_warning("downrankVariableType(type: <NULL>)");
    }
    return newVariableType(type->rank - 1);
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

char *stringFromDeclaration(VariableDeclaration *declaration) {
    GString *result = g_string_new("");
    char *type_s = stringFromType(declaration->type);
    g_string_printf(result, "<VariableDeclaration at %p> %s : %s", declaration, declaration->name, type_s);
    g_free(type_s);
    return g_string_free(result, FALSE);
}

VariableDeclaration *newVariableDeclaration(char *name, VariableType *type) {
    char *type_s = stringFromType(type);
    g_message("newVariableDeclaration(name: %s, type: %s)", name, type_s);
    g_free(type_s);

    VariableDeclaration *result = g_new(VariableDeclaration, 1);
    result->name = name;
    result->type = type;
    
    char *result_s = stringFromDeclaration(result);
    g_message("newVariableDeclaration() = %s", result_s);
    g_free(result_s);
    
    return result;
}

ScopeFrame *newScopeFrame() {
    g_message("newScopeFrame()");

    ScopeFrame *result = g_new(ScopeFrame, 1);
    result->len = 0;
    result->declarations = NULL;

    g_message("newScopeFrame() = <ScopeFrame at %p>", result);
    return result;
}

ScopeFrame *frameAddDeclaration(ScopeFrame *frame, VariableDeclaration *declaration) {
    char *declaration_s = stringFromDeclaration(declaration);
    g_message("frameAddDeclaration(frame: <ScopeFrame at %p>, declaration: %s)", frame, declaration_s);
    g_free(declaration_s);

    ScopeFrame *result = g_new(ScopeFrame, 1);
    result->len = frame->len+1;
    result->declarations = g_slist_prepend(frame->declarations, declaration);

    return result;
}

void printScopeFrame(ScopeFrame *scope) {
    printf("<ScopeFrame at %p>\n", scope);

    for (GSList *it = scope->declarations; it != NULL; it = it->next) {
        VariableDeclaration *declaration = it->data;
        char *declaration_s = stringFromDeclaration(declaration);
        puts(declaration_s);
        g_free(declaration_s);
    }
}

ScopeChain *newScopeChain() {
    g_message("newScopeChain()");

    ScopeChain *result = g_new(ScopeChain, 1);
    result->len = 0;
    result->frames = NULL;

    g_message("newScopeChain() = <ScopeChain at %p>", result);
    return result;
}

ScopeChain *chainPushFrame(ScopeChain *chain, ScopeFrame *frame) {
    g_message("chainPushFrame(chain: %p, frame: %p)", chain, frame);

    ScopeChain *result = g_new(ScopeChain, 1);
    result->len = chain->len+1;
    result->frames = g_slist_prepend(chain->frames, frame);

    g_message("chainPushFrame() = %p", result);
    return result;
}


ScopeChain *chainAddDeclaration(ScopeChain *chain, VariableDeclaration *declaration) {
    char *declaration_s = stringFromDeclaration(declaration);
    g_message("chainAddDeclaration(chain: <ScopeChain at %p>, declaration: %s)", chain, declaration_s);
    g_free(declaration_s);

    ScopeChain *result = g_new(ScopeChain, 1);
    ScopeFrame *top_frame = chain->frames->data;
    
    result->len = chain->len;  
    result->frames = g_slist_prepend(chain->frames->next, 
                                     frameAddDeclaration(top_frame, declaration));

    g_message("chainAddDeclaration() = <ScopeChain at %p>", result);
    return result;
}

void printScopeChain(ScopeChain *chain) {
    printf("<ScopeChain at %p>\n", chain);
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

void debugScopeChain(char *label, ScopeChain *chain) {
    if (!_debugScopeChain) return;

    puts(label);
    printScopeChain(chain);
}

void checkDuplicateParameters(char *identifier, ScopeFrame *parameters) {
    g_message("checkDuplicateParameters(identifier: %s)", identifier);
    //GSList *declarations = g_slist_reverse(parameters->declarations);
    GHashTable *visited = g_hash_table_new(&g_str_hash, &g_str_equal);

    for (GSList *it = parameters->declarations; it != NULL; it = it->next) {
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
}

void checkIdentifierInScope(char *identifier, ScopeChain *scope) {
    g_message("checkIdentifierInScope(identifier: %s)", identifier);
    printScopeChain(scope);
    if (findDeclarationInScope(identifier, scope) != NULL) {
        g_critical("checkIdentifierInScope():\nidentifier not in scope: %s", identifier);
        exit(StatusSemanticError);
    }
}

VariableDeclaration *findDeclarationInFrame(char *identifier, ScopeFrame *frame) {
    g_message("findDeclarationInFrame(identifier: %s, frame: <ScopeFrame at %p>", identifier, frame);
    for (GSList *it = frame->declarations; it != NULL; it = it->next) {
        VariableDeclaration *declaration = it->data;
        if (g_strcmp0(identifier, declaration->name) == 0) {
            char *declaration_s = stringFromDeclaration(declaration);
            g_message("findDeclarationInFrame() = %s", declaration_s);
            g_free(declaration_s);

            return declaration;
        }
    }    

    g_message("findDeclarationInFrame() = NULL");
    return NULL;
}

VariableDeclaration *findDeclarationInScope(char *identifier, ScopeChain *scope) {
    g_message("findDeclarationInScope(identifier: %s, scope: <ScopeChain at %p>)", identifier, scope);

    for (GSList *it = scope->frames; it != NULL; it = it->next) {
        ScopeFrame *frame = it->data;
        VariableDeclaration *declaration = findDeclarationInFrame(identifier, frame);
        if (declaration != NULL) {
            char *declaration_s = stringFromDeclaration(declaration);
            g_message("findDeclarationInScope() = %s", declaration_s);
            g_free(declaration_s);

            return declaration;
        }
    }

    g_message("findDeclarationInScope() = NULL");
    return NULL;
}

VariableType *findTypeInScope(char *identifier, ScopeChain *scope) {
    g_message("findTypeInScope(identifier: %s, scope: <ScopeChain at %p>)", identifier, scope);

    VariableDeclaration *declaration = findDeclarationInScope(identifier, scope);
    if (declaration != NULL) {
        char *type_s = stringFromType(declaration->type);
        g_message("findTypeInScope() = <VariableType - %s>", type_s);
        g_free(type_s);

        return declaration->type;
    } else {
        g_message("findTypeInScope() = NULL");

        return NULL;
    }
}

void checkIsInteger(VariableType *type) {
    if (type == NULL) {
        g_warning("checkIsInteger(type: <NULL>)");
        return;
    }

    char *type_s = stringFromType(type);
    g_message("checkIsInteger(type: <VariableType at %p - %s>)", type, type_s);
    g_free(type_s);

    if (type->rank != 0) {
        g_critical("expression must be an int");
        exit(StatusSemanticError);
    }
}

void checkIsArray(VariableType *type) {
    if (type == NULL) {
        g_warning("checkIsArray(type: <NULL>)");
        return;
    }

    char *type_s = stringFromType(type);
    g_message("checkIsArray(type: <VariableType at %p - %s>)", type, type_s);
    g_free(type_s);

    if (type->rank <= 0) {
        g_critical("expression must be an array");
        exit(StatusSemanticError);
    }
}

char *stringFromType0(VariableType *type) {
    if (type == NULL) return g_strdup("<NULL>");

    char *type_s = stringFromType(type);
    GString *result = g_string_new("");
    g_string_printf(result, "<VariableType at %p - %s>", type, type_s);
    g_free(type_s);
    return g_string_free(result, FALSE);
}

void checkSameType(VariableType *left, VariableType *right) {
    char *left_s = stringFromType0(left);
    char *right_s = stringFromType0(right);

    if (left == NULL || right == NULL) {
        g_warning("checkSameType(left: %s, right: %s)", left_s, right_s);
        return;
    }

    g_message("checkSameType(left: %s, right: %s)", left_s, right_s);
    

    if (!eqVariableType(left, right)) {
        g_critical("checkSameType(): left-hand-type must be equal to right-hand-type");
        exit(StatusSemanticError);
    }
    g_free(left_s);
    g_free(right_s);
}
