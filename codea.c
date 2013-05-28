#include <glib.h>
#include "codea.h"


BurgNode *newConstantNode(long value) {
    BurgNode *result = g_new0(BurgNode, 1);
    result->operator = BurgOpConst;
    result->value = value;
    return result;
}


BurgNode *newConstantFoldingNode(BurgOperator operator, long left, long right) {
    BurgNode *result = g_new0(BurgNode, 1);
    result->operator = operator;
    result->kids[0] = newConstantNode(left);
    result->kids[1] = newConstantNode(right);
    return result;
}

BurgNode *newAddNode(long left, long right) {
    return newConstantFoldingNode(BurgOpAdd, left, right);
}

BurgNode *newMulNode(long left, long right) {
    return newConstantFoldingNode(BurgOpMul, left, right);
}

BurgNode *newSubNode(long left, long right) {
    return newConstantFoldingNode(BurgOpSub, left, right);
}


BurgNode *newOpAssignNode(BurgOperator operator, char *reg_name, BurgNode *value) {
    BurgNode *result = g_new0(BurgNode, 1);
    result->operator = operator;
    result->kids[0] = newRegisterNode(reg_name);
    result->kids[1] = value;
    return result;
}

BurgNode *newAddAssignNode(char *reg_name, BurgNode *value) {
    return newOpAssignNode(BurgOpAddAssign, reg_name, value);
}

BurgNode *newMulAssignNode(char *reg_name, BurgNode *value) {
    return newOpAssignNode(BurgOpMulAssign, reg_name, value);
}

BurgNode *newSubAssignNode(char *reg_name, BurgNode *value) {
    return newOpAssignNode(BurgOpSubAssign, reg_name, value);
}


BurgNode *newDereferenceNode(BurgNode* address) {
    BurgNode *result = g_new0(BurgNode, 1);
    result->operator = BurgOpDereference;
    result->kids[0] = address;
    return result;
}

BurgNode *newRegisterNode(char* reg_name) {
    BurgNode *result = g_new0(BurgNode, 1);
    result->operator = BurgOpRegister;
    result->reg_name = reg_name;
    return result;
}

BurgNode *newAssignNode(char *reg_name, BurgNode *value) {
    BurgNode *result = g_new0(BurgNode, 1);
    result->operator = BurgOpAssign;
    result->kids[0] = newRegisterNode(reg_name);
    result->kids[1] = value;
    return result;
}

BurgNode *newReturnNode(BurgNode *value) {
    BurgNode *result = g_new0(BurgNode, 1);
    result->operator = BurgOpReturn;
    result->kids[0] = value;
    return result;
}
