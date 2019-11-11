#include "hoc.h"
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>

extern void execerror(const char *c, char *s);

static Symbol *symlist = 0;

Symbol *lookup(char *s)
{
  Symbol *sp;
  
  for (sp = symlist; sp != (Symbol*) 0; sp = sp->next)
    if (strcmp(sp->name, s) == 0)
      return sp;

  return 0;
}

void *emalloc(unsigned n)
{
  void *p = malloc(n);

  if (p == 0)
    execerror("out of memory", (char*)0);

  return p;
}

Symbol *install(char *s, int t, double d)
{
  Symbol *sp;
  sp = (Symbol*) emalloc(sizeof(Symbol));
  sp->name = emalloc(strlen(s) + 1);  // +1 for \0
  strcpy(sp->name, s);
  sp->type = t;
  sp->u.val = d;
  sp->next = symlist;
  symlist = sp;
  return sp;
}

