%{  
#include <stdio.h>
#include <signal.h>
#include <setjmp.h>
#include <ctype.h>       

int yyerror(const char *s);
int yylex();
int execerror(const char*s, char *t);

double mem[26];
jmp_buf begin;
 
%}
%union {
  double val;
  int index;
}
%token  <val>   NUMBER
%token  <index> VAR
%type   <val>   expr
%right '='
%left  '+' '-'
%left  '*' '/'
%left  UNARYMINUS
%%
list:   /* nothing */
       | list '\n'
       | list expr '\n'      { printf("\t%.8g\n", $2); }
       | list error '\n'     { yyerrok; }
       ;
 expr:  NUMBER                
   | VAR                      { $$ = mem[$1]; }
   | VAR '=' expr             { $$ = mem[$1] = $3; }
   | '-' expr %prec UNARYMINUS { $$ = -$2; }
   | expr '+' expr            { $$ = $1 + $3; }
   | expr '-' expr            { $$ = $1 - $3; }
   | expr '*' expr            { $$ = $1 * $3; }
   | expr '/' expr            {
     if ($3 == 0.0)
       execerror("division by zero", "");
     $$ = $1 / $3; }
   | '(' expr ')'             { $$ = $2; }
   ;
%%
       /* end of grammar */

char *progname;
int lineno = 1;

int yylex()
{
  int c;

  while ((c = getchar()) == ' ' || c == '\t')
    ;

  if (c == EOF)
    return 0;

  if (c == '.' || isdigit(c)) { /* number */
    ungetc(c, stdin);
    scanf("%lf", &yylval.val);
    return NUMBER;
  }

  if (islower(c)) {
    yylval.index = c - 'a';
    return VAR;
  }

  if (c == '\n')
    lineno++;

  return c;
}

void warning(const char *s, char *t)
{
  fprintf(stderr, "%s: %s", progname, s);
  if (t)
    fprintf(stderr, " %s", t);
  fprintf(stderr, " near line %d\n", lineno);
}

int yyerror(const char *s)
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
  setjmp(begin);
  signal(SIGFPE, fpecatch);
  yyparse();
}
