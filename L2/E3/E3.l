%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <ctype.h>

  int n_lineas = 0;
  int n_tokens = 0;
%}

/* Macros */
LETRA       [a-zA-Z]
DIGITO      [0-9]
VARIABLE [a-zA-Z_]

%option noyywrap
%option yylineno

%%
#.* {printf("[COMENTARIO]       Linea %3d: %s\n", yylineno, yytext);}

{VARIABLE}({VARIABLE}|{DIGITO})*  {
	if (strcmp(yytext, "DIV") == 0 || strcmp(yytext, "MOD") == 0) {
		REJECT;
  }

  printf("[VARIABLE]         Linea %3d: '%s'\n", yylineno, yytext);
	n_tokens++;
}

[+-]?{DIGITO}+  {
	printf("[ENTERO]           Linea %3d: %s\n", yylineno, yytext);
	n_tokens++;
}

[+-]?{DIGITO}*"\."{DIGITO}+   {
  printf("[REAL FLOTANTE]    Linea %3d: %s\n", yylineno, yytext);
  n_tokens++;
}

[+-]?({DIGITO}*"\."{DIGITO}+|{DIGITO}+)[eE][+-]?{DIGITO}+  {
  printf("[REAL EXPONENCIAL] Linea %3d: %s\n", yylineno, yytext);
  n_tokens++;
}

"="             { printf("[OPERADOR]         Linea %3d: '='  (asignacion)\n", yylineno); n_tokens++; }
"+"             { printf("[OPERADOR]         Linea %3d: '+'  (suma)\n", yylineno); n_tokens++; }
"-"             { printf("[OPERADOR]         Linea %3d: '-'  (resta)\n", yylineno); n_tokens++; }
"*"             { printf("[OPERADOR]         Linea %3d: '*'  (multiplicacion)\n", yylineno); n_tokens++; }
"/"             { printf("[OPERADOR]         Linea %3d: '/'  (division)\n", yylineno); n_tokens++; }
"DIV"           { printf("[OPERADOR]         Linea %3d: 'DIV' (division entera)\n", yylineno); n_tokens++; }
"MOD"           { printf("[OPERADOR]         Linea %3d: 'MOD' (modulo)\n", yylineno); n_tokens++; }
"("             { printf("[PARENTESIS]       Linea %3d: '('  (apertura)\n", yylineno); n_tokens++; }
")"             { printf("[PARENTESIS]       Linea %3d: ')'  (cierre)\n", yylineno); n_tokens++; }

[ \t\r]+        {/*Ignorar espacios y tabulaciones */}
\n              {n_lineas++;}
.               { printf("[ERROR]            Linea %3d: Caracter/Patron no reconocido: '%s'\n", yylineno, yytext); }
%%

int main() {
  yylex();

  printf("\n===================================================================\n");
  printf("  - Total de tokens reconocidos: %d\n", n_tokens);
  printf("  - Total de lineas procesadas:  %d\n", yylineno);
  printf("===================================================================\n");

  return 0;
}