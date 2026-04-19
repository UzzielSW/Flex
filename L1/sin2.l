%{
#include <stdio.h>
#include "y.tab.h"
%}

/* Para que flex no use yywrap, ahorra problemas al compilar */
%option noyywrap
%option yylineno

separador ([ \t""])+
letra [a-zA-Z]
digito [0-9]
identificador {letra}({letra}|{digito})*
constEntera {digito}({digito})*

%%

{separador} {/* omitir */}
{constEntera} {return (CONSTENTERA);}
":=" {return (OPAS);}
"+" {return (MAS);}
{identificador} {return (IDENTIFICADOR);}
"(" {return (APAR);}
")" {return (CPAR);}
\n {return (NL);}
. ECHO;

%%
