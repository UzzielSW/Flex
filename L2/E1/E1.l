%{
  #include <stdio.h>
%}

%option noyywrap

/* Definiciones de macros/patrones */
DIGITO [0-9]


/* REGLAS (Patrones → Acciones) */
%%
{DIGITO}{DIGITO}*       {printf("\n Un entero [%d]", atoi(yytext));}
[a-zA-Z_][a-zA-Z0-9_]*  {printf("\n Una variable [%s]", yytext);
                        printf(" que tiene %d caracteres", yyleng);}
.                       ;
%%

int main() {
  yylex();

  return 0;
}