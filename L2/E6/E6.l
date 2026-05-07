%{
  #include <stdio.h>
%}

%option noyywrap
%option yylineno

%%
#.*\n           { /* omitir comentarios */}
.               { printf("%s", yytext); }
%%

int main() {
  yylex();

  return 0;
}