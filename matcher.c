typedef struct burm_state *STATEPTR_TYPE;

//#include <glib.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "codea.h"
#ifndef ALLOC
#define ALLOC(n) malloc(n)
#endif

#ifndef burm_assert
#define burm_assert(x,y) if (!(x)) { extern void abort(void); y; abort(); }
#endif

#define burm_return_NT 1
#define burm_reg_NT 2
#define burm_const_NT 3
#define burm_Reg_NT 4
int burm_max_nt = 4;

struct burm_state {
	int op;
	STATEPTR_TYPE left, right;
	short cost[5];
	struct {
		unsigned burm_return:2;
		unsigned burm_reg:1;
		unsigned burm_const:1;
		unsigned burm_Reg:1;
	} rule;
};

static short burm_nts_0[] = { burm_reg_NT, 0 };
static short burm_nts_1[] = { burm_const_NT, 0 };
static short burm_nts_2[] = { burm_Reg_NT, 0 };
static short burm_nts_3[] = { 0 };

short *burm_nts[] = {
	0,	/* 0 */
	burm_nts_0,	/* 1 */
	burm_nts_1,	/* 2 */
	burm_nts_2,	/* 3 */
	burm_nts_3,	/* 4 */
};

char burm_arity[] = {
	0,	/* 0 */
	0,	/* 1=Const */
	0,	/* 2=Add */
	0,	/* 3=Mul */
	0,	/* 4=Sub */
	0,	/* 5=AddAssign */
	0,	/* 6=MulAssign */
	0,	/* 7=SubAssign */
	0,	/* 8=Dereference */
	0,	/* 9=Register */
	0,	/* 10=Assign */
	1,	/* 11=Return */
};

static short burm_decode_return[] = {
	0,
	1,
	2,
};

static short burm_decode_reg[] = {
	0,
	3,
};

static short burm_decode_const[] = {
	0,
	4,
};

static short burm_decode_Reg[] = {
	0,
};

int burm_rule(STATEPTR_TYPE state, int goalnt) {
	burm_assert(goalnt >= 1 && goalnt <= 4, PANIC("Bad goal nonterminal %d in burm_rule\n", goalnt));
	if (!state)
		return 0;
	switch (goalnt) {
	case burm_return_NT:
		return burm_decode_return[state->rule.burm_return];
	case burm_reg_NT:
		return burm_decode_reg[state->rule.burm_reg];
	case burm_const_NT:
		return burm_decode_const[state->rule.burm_const];
	case burm_Reg_NT:
		return burm_decode_Reg[state->rule.burm_Reg];
	default:
		burm_assert(0, PANIC("Bad goal nonterminal %d in burm_rule\n", goalnt));
	}
	return 0;
}

static void burm_closure_Reg(STATEPTR_TYPE, int);

static void burm_closure_Reg(STATEPTR_TYPE p, int c) {
	if (c + 0 < p->cost[burm_reg_NT]) {
		p->cost[burm_reg_NT] = c + 0;
		p->rule.burm_reg = 1;
	}
}

STATEPTR_TYPE burm_state(int op, STATEPTR_TYPE left, STATEPTR_TYPE right) {
	int c;
	STATEPTR_TYPE p, l = left, r = right;

	if (burm_arity[op] > 0) {
		p = (STATEPTR_TYPE)ALLOC(sizeof *p);
		burm_assert(p, PANIC("ALLOC returned NULL in burm_state\n"));
		p->op = op;
		p->left = l;
		p->right = r;
		p->rule.burm_return = 0;
		p->cost[1] =
		p->cost[2] =
		p->cost[3] =
		p->cost[4] =
			32767;
	}
	switch (op) {
	case 1: /* Const */
		{
			static struct burm_state z = { 1, 0, 0,
				{	0,
					32767,
					32767,
					0,	/* const: Const */
					32767,
				},{
					0,
					0,
					1,	/* const: Const */
					0,
				}
			};
			return &z;
		}
	case 2: /* Add */
		{
			static struct burm_state z = { 2, 0, 0,
				{	0,
					32767,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 3: /* Mul */
		{
			static struct burm_state z = { 3, 0, 0,
				{	0,
					32767,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 4: /* Sub */
		{
			static struct burm_state z = { 4, 0, 0,
				{	0,
					32767,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 5: /* AddAssign */
		{
			static struct burm_state z = { 5, 0, 0,
				{	0,
					32767,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 6: /* MulAssign */
		{
			static struct burm_state z = { 6, 0, 0,
				{	0,
					32767,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 7: /* SubAssign */
		{
			static struct burm_state z = { 7, 0, 0,
				{	0,
					32767,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 8: /* Dereference */
		{
			static struct burm_state z = { 8, 0, 0,
				{	0,
					32767,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 9: /* Register */
		{
			static struct burm_state z = { 9, 0, 0,
				{	0,
					32767,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 10: /* Assign */
		{
			static struct burm_state z = { 10, 0, 0,
				{	0,
					32767,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 11: /* Return */
		assert(l);
		{	/* return: Return(const) */
			c = l->cost[burm_const_NT] + 1;
			if (c + 0 < p->cost[burm_return_NT]) {
				p->cost[burm_return_NT] = c + 0;
				p->rule.burm_return = 2;
			}
		}
		{	/* return: Return(reg) */
			c = l->cost[burm_reg_NT] + 1;
			if (c + 0 < p->cost[burm_return_NT]) {
				p->cost[burm_return_NT] = c + 0;
				p->rule.burm_return = 1;
			}
		}
		break;
	default:
		burm_assert(0, PANIC("Bad operator %d in burm_state\n", op));
	}
	return p;
}

#ifdef STATE_LABEL
static void burm_label1(NODEPTR_TYPE p) {
	burm_assert(p, PANIC("NULL tree in burm_label\n"));
	switch (burm_arity[OP_LABEL(p)]) {
	case 0:
		STATE_LABEL(p) = burm_state(OP_LABEL(p), 0, 0);
		break;
	case 1:
		burm_label1(LEFT_CHILD(p));
		STATE_LABEL(p) = burm_state(OP_LABEL(p),
			STATE_LABEL(LEFT_CHILD(p)), 0);
		break;
	case 2:
		burm_label1(LEFT_CHILD(p));
		burm_label1(RIGHT_CHILD(p));
		STATE_LABEL(p) = burm_state(OP_LABEL(p),
			STATE_LABEL(LEFT_CHILD(p)),
			STATE_LABEL(RIGHT_CHILD(p)));
		break;
	}
}

STATEPTR_TYPE burm_label(NODEPTR_TYPE p) {
	burm_label1(p);
	return STATE_LABEL(p)->rule.burm_return ? STATE_LABEL(p) : 0;
}

NODEPTR_TYPE *burm_kids(NODEPTR_TYPE p, int eruleno, NODEPTR_TYPE kids[]) {
	burm_assert(p, PANIC("NULL tree in burm_kids\n"));
	burm_assert(kids, PANIC("NULL kids in burm_kids\n"));
	switch (eruleno) {
	case 2: /* return: Return(const) */
	case 1: /* return: Return(reg) */
		kids[0] = LEFT_CHILD(p);
		break;
	case 3: /* reg: Reg */
		kids[0] = p;
		break;
	case 4: /* const: Const */
		break;
	default:
		burm_assert(0, PANIC("Bad external rule number %d in burm_kids\n", eruleno));
	}
	return kids;
}

int burm_op_label(NODEPTR_TYPE p) {
	burm_assert(p, PANIC("NULL tree in burm_op_label\n"));
	return OP_LABEL(p);
}

STATEPTR_TYPE burm_state_label(NODEPTR_TYPE p) {
	burm_assert(p, PANIC("NULL tree in burm_state_label\n"));
	return STATE_LABEL(p);
}

NODEPTR_TYPE burm_child(NODEPTR_TYPE p, int index) {
	burm_assert(p, PANIC("NULL tree in burm_child\n"));
	switch (index) {
	case 0:	return LEFT_CHILD(p);
	case 1:	return RIGHT_CHILD(p);
	}
	burm_assert(0, PANIC("Bad index %d in burm_child\n", index));
	return 0;
}

#endif
void burm_reduce(NODEPTR_TYPE bnode, int goalnt)
{
  int ruleNo = burm_rule (STATE_LABEL(bnode), goalnt);
  short *nts = burm_nts[ruleNo];
  NODEPTR_TYPE kids[100];
  int i;

  if (ruleNo==0) {
    fprintf(stderr, "tree cannot be derived from start symbol");
    exit(1);
  }
  burm_kids (bnode, ruleNo, kids);
  for (i = 0; nts[i]; i++)
    burm_reduce (kids[i], nts[i]);    /* reduce kids */

#if DEBUG
  printf ("%s", burm_string[ruleNo]);  /* display rule */
#endif

  switch (ruleNo) {
  case 1:
 printf("movq %s, %%rax", kids[0]->reg_name);
    break;
  case 2:
 printf("movq $%ld, %%rax", kids[0]->value);
    break;
  case 3:

    break;
  case 4:

    break;
  default:    assert (0);
  }
}
