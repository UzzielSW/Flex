%{
  #include <stdio.h>

  int num_lineas = 0, num_caracteres = 0;
%}

%option noyywrap

%%
\n      {++num_lineas; ++num_caracteres;}
.       {++num_caracteres;}
%%

int main(void) {
  yylex();
  printf("Total de lineas: %d\n", num_lineas);
  printf("Total de caracteres: %d\n", num_caracteres);

  return 0;
}
