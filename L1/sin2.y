%{
#include <stdio.h>
#include <stdlib.h>

extern int yylineno;

/* Declaraciones para que el compilador de C moderno */
int yylex(void);
void yyerror(const char *s);
%}

%token IDENTIFICADOR OPAS CONSTENTERA NL MAS APAR CPAR
%start instrucciones

%%

instrucciones : instrucciones instruccion | instruccion;
instruccion : IDENTIFICADOR OPAS expresion NL;
termino : IDENTIFICADOR | CONSTENTERA | APAR expresion CPAR;
expresion : termino | expresion MAS termino;

%%

/* Función de error al estilo C moderno (ANSI C) */
void yyerror(const char *s) {
fprintf(stderr, "Error sintactico en linea %d: %s\n", yylineno, s);
}

/* El main ahora devuelve un entero, como exige el estándar C */
// int main(void) {
// 		yyparse();

// 		return 0;
// }
int main(void) {
  int resultado = yyparse();

  if (resultado == 0) {
      printf("Analisis completado exitosamente.\n");
  } else {
      printf("Se encontraron errores durante el analisis.\n");
  }

  return resultado;
}