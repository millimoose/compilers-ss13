#ifndef CODEA_H
#define CODEA_H

enum _BurgOperator {
    BurgOpConst         = 1,
    BurgOpAdd           = 2,
    BurgOpMul           = 3,
    BurgOpSub           = 4,
    BurgOpAddAssign     = 5,
    BurgOpMulAssign     = 6,
    BurgOpSubAssign     = 7,
    BurgOpDereference   = 8,
    BurgOpRegister      = 9,
    BurgOpAssign        = 10,
    BurgOpReturn        = 11
};

typedef enum _BurgOperator BurgOperator;
typedef struct burm_state *STATEPTR_TYPE;

struct _BurgNode {
    BurgOperator operator;
    struct _BurgNode *kids[2];
    STATEPTR_TYPE state;

    char *reg_name;
    long value;
};
typedef struct _BurgNode BurgNode;
typedef BurgNode *PBurgNode;

#define NODEPTR_TYPE    PBurgNode
#define OP_LABEL(p)     ((p)->operator)
#define LEFT_CHILD(p)   ((p)->kids[0])
#define RIGHT_CHILD(p)  ((p)->kids[1])
#define PANIC           printf
#define STATE_LABEL(p)  ((p)->state)

/*
 */

BurgNode *newConstantNode(long value);
BurgNode *newAddNode(long left, long right);
BurgNode *newMulNode(long left, long right);
BurgNode *newSubNode(long left, long right);
BurgNode *newAddAssignNode(char *reg_name, BurgNode *value);
BurgNode *newMulAssignNode(char *reg_name, BurgNode *value);
BurgNode *newSubAssignNode(char *reg_name, BurgNode *value);
BurgNode *newDereferenceNode(BurgNode* address);
BurgNode *newRegisterNode(char* reg_name);
BurgNode *newAssignNode(char *reg_name, BurgNode *value);
BurgNode *newReturnNode(BurgNode *value);

#endif
