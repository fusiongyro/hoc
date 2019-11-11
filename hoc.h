typedef struct Symbol {
  char *name;
  short type;   /* VAR, BLTIN, UNDEF */
  union {
    double val;        // if VAR
    double (*ptr)();   // if BLTIN
  } u;
  struct Symbol *next;
} Symbol;

Symbol *install(), *lookup();

typedef union Datum {
  double val;
  Symbol *sym;
} Datum;

extern Datum pop();

typedef void (*Inst)();
#define STOP ((Inst)0)

extern Inst prog[];
extern void eval(), add(), sub(), mul(), Div(), negate(), power(), Pop();
extern void assign(), bltin(), varpush(), constpush(), print();
