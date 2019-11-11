%{
#include "hoc.h"
#include <stdio.h>
#include <signal.h>
#include <setjmp.h>
#include <ctype.h>       
  
#define code2(c1,c2)     code(c1); code(c2);
#define code3(c1,c2,c3)  code(c1); code(c2); code(c3);

extern Inst* code(Inst f);
extern double Pow(double x, double y);
extern void init();
extern void initcode();
extern void execute(Inst p);

void yyerror(const char *s);
int yylex();
int execerror(const char*s, char *t);
 
double mem[26];
jmp_buf begin;
 
%}
%union {
  Symbol *sym;
  Inst   *inst;
}
%token  <sym>   NUMBER VAR BLTIN UNDEF
%right '='
%left  '+' '-'
%left  '*' '/'
%left  UNARYMINUS
%right '^'
%%
list:   /* nothing */
  | list '\n'
  | list asgn '\n'      { code2(Pop, STOP); return 1; }
  | list expr '\n'      { code2(print, STOP); return 1; }
  | list error '\n'     { yyerrok; }
  ;
asgn:    VAR '=' expr { code3(varpush, (Inst)$1, assign); }
   ;
expr:  NUMBER { code2(constpush, (Inst)$1); }
   | VAR { code3(varpush, (Inst)$1, eval); }
   | asgn
   | BLTIN '(' expr ')' { code2(bltin, (Inst)$1->u.ptr); }
   | '(' expr ')'
   | expr '+' expr            { code(add); }
   | expr '-' expr            { code(sub); }
   | expr '*' expr            { code(mul); }
   | expr '/' expr            { code(Div); }
   | expr '^' expr            { code(power); }
   | '-' expr %prec UNARYMINUS { code(negate); }
   ;
%%
       /* end of grammar */

char *progname;
int lineno = 1;

void warning(const char *s, char *t)
{
  fprintf(stderr, "%s: %s", progname, s);
  if (t)
    fprintf(stderr, " %s", t);
  fprintf(stderr, " near line %d\n", lineno);
}

void yyerror(const char *s)
{
  warning(s, (char*)0);
}

int execerror(const char*s, char *t)
{
  warning(s, t);
  longjmp(begin, 0);
}

void fpecatch(int i)
{
  execerror("floating point exception", (char*)0);
}


int main(int argc, char* argv[])
{
  progname = argv[0];
  init();
  setjmp(begin);
  signal(SIGFPE, fpecatch);
  for (initcode(); yyparse(); initcode())
    execute(prog);
  return 0;
}
