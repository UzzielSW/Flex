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
"\t"{2,}         { printf("\t"); n_tabs_normalizados++; }
.                { printf("%s", yytext); }
\n               { n_lineas++; printf("\n"); }
%%

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) {
            fprintf(stderr, "Error: No se pudo abrir '%s'\n", argv[1]);
            return 1;
        }
        yyin = f;
    } else {
        printf("Modo: Leyendo desde entrada estandar (stdin)\n");
        printf("Escribe texto y presiona Ctrl+D para finalizar.\n\n");
    }

    yylex();

    printf("\n===================================================================\n");
    printf("  - Lineas procesadas:               %d\n", n_lineas);
    printf("  - Grupos de espacios normalizados: %d\n", n_espacios_normalizados);
    printf("  - Grupos de tabs normalizados:     %d\n", n_tabs_normalizados);
    printf("===================================================================\n");

    if (argc > 1) fclose(yyin);
    return 0;
}
