#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <glib.h>

#include "ag.h"

VariableType *newVariableType(int rank) {
    // g_message("newVariableType(rank=%d)", rank);
    VariableType *result = g_new(VariableType, 1);
    result->rank = rank;
    result->primitive = PrimitiveInt;
    return result;
}

static char *PrimitiveTypeNames[] = {
    "<undefined>", "int"
};  

char *stringFromType(VariableType *type) {
    // g_message("stringFromType(type=%p)", type);
    GString *result = g_string_new("");
    for (int i = 0; i < type->rank; i++) {
      g_string_append(result, "array of ");
    }
    g_string_append(result, PrimitiveTypeNames[type->primitive]);
    return g_string_free(result, FALSE);
}

VariableDeclaration *newVariableDeclaration(char *name, VariableType *type) {
    // g_message("newVariableDeclaration(name=%p, type=%p)", name, type);
    VariableDeclaration *result = g_new(VariableDeclaration, 1);
    result->name = name;
    result->type = type;
    return result;
}

char *stringFromDeclaration(VariableDeclaration *declaration) {
    // g_message("stringFromDeclaration(declaration=%p)", declaration);
    GString *result = g_string_new("");
    char *type_string = stringFromType(declaration->type);
    g_string_printf(result, "%s : %s", declaration->name, type_string);
    g_free(type_string);
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
    // g_message("printScopeFrame(scope=%p)", scope);
    for (GSList *it = scope->declarations; it != NULL; it = it->next) {
        VariableDeclaration *declaration = it->data;
        char *declaration_string = stringFromDeclaration(declaration);
        puts(declaration_string);
        g_free(declaration_string);
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
    ScopeFrame *topFrame = chain->frames->data;
    
    result->len = chain->len;  
    result->frames = g_slist_prepend(chain->frames->next, 
                                           frameAddDeclaration(topFrame, declaration));
    
    frameAddDeclaration(topFrame, declaration);
    return result;
}

void printScopeChain(ScopeChain *chain) {
    // g_message("printChain(chain=%p)", chain);
    
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


