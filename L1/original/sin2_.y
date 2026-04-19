%{
#include<stdio.h>
%}

%token IDENTIFICADOR OPAS CONSTENTERA NL MAS APAR CPAR
%start instrucciones

%%
instrucciones : instrucciones instruccion | instruccion;
instruccion : IDENTIFICADOR OPAS expresion NL ;
termino : IDENTIFICADOR| CONSTENTERA|APAR expresion CPAR;
expresion : termino | expresion MAS termino ;


%%

yyerror(s)
char *s;
{
    printf("%s\n",s);
}
 main()
 {
     yyparse();
 }