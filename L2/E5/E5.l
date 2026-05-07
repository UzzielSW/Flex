%{
  #include <stdio.h>
  #include <string.h>

  int n_espacios_normalizados = 0;
  int n_tabs_normalizados = 0;
  int n_lineas = 0;
%}

%option noyywrap
%option yylineno

%%
" "{2,}          { printf(" "); n_espacios_normalizados++; }
"\t"{2,}         { printf("[t]"); n_tabs_normalizados++; }
.                { printf("%s", yytext); }
\n               { n_lineas++; printf("\n"); }
%%

int main() {
  yylex();

  printf("\n===================================================================\n");
  printf("  - Lineas procesadas:               %d\n", n_lineas);
  printf("  - Grupos de espacios normalizados: %d\n", n_espacios_normalizados);
  printf("  - Grupos de tabs normalizados:     %d\n", n_tabs_normalizados);
  printf("===================================================================\n");

  return 0;
}
