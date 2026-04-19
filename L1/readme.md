# 1. Explicacion de `sin2.l`

## 1. Sección de Declaraciones (`%{ ... %}`)

```flex
%{
#include <stdio.h>
#include "y.tab.h"
%}
```


| Elemento             | Descripción                                                                                                                  |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `%{ ... %}`          | Bloque de código C que se copia **literalmente** al principio del archivo C generado                                         |
| `#include <stdio.h>` | Incluye la biblioteca estándar de entrada/salida (necesaria para `printf`, `ECHO`, etc.)                                     |
| `"y.tab.h"`          | **Archivo de cabecera generado por Bison/Yacc** que contiene las definiciones de tokens (`CONSTENTERA`, `OPAS`, `MAS`, etc.) |


> **Nota importante**: Este lexer está diseñado para trabajar junto con un parser de Bison/Yacc. Los valores de retorno (`return (CONSTENTERA)`) son constantes definidas en `y.tab.h`.

---

## 2. Opciones de Flex (`%option`)


| Opción     | Significado                                                                                                                                              |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `noyywrap` | Evita que Flex busque la función `yywrap()`. Sin esta opción, Flex requiere que definas `yywrap()` o enlaces con `-lfl`. Esto simplifica la compilación. |


> **Alternativa sin `%option`**: Tendrías que definir `int yywrap() { return 1; }` al final del archivo.

---

## 3. Definiciones de Patrones (sección de nombres)

```flex
separador ([ \t""])+
letra [a-zA-Z]
digito [0-9]
identificador {letra}({letra}|{digito})*
constEntera {digito}({digito})*
```


| Nombre          | Patrón                | Significado                                                     |
| --------------- | --------------------- | --------------------------------------------------------------- |
| `separador`     | `([ \t""])+`          | **Espacios, tabulaciones y comillas dobles** (una o más veces). |
| `letra`         | `[a-zA-Z]`            | Cualquier letra mayúscula o minúscula                           |
| `digito`        | `[0-9]`               | Cualquier dígito del 0 al 9                                     |
| `identificador` | `{letra}({letra}      | {digito})`*                                                     |
| `constEntera`   | `{digito}({digito})`* | Uno o más dígitos consecutivos (números enteros).               |


---

## 4. Reglas de Traducción (`%% ... %%`)

```flex
%%

{separador}     {/* omitir */}
{constEntera}   {return (CONSTENTERA);}
":="            {return (OPAS);}
"+"             {return (MAS);}
{identificador} {return (IDENTIFICADOR);}
"("             {return (APAR);}
")"             {return (CPAR);}
\n              {return (NL);}
.               ECHO;

%%
```

### Orden de las reglas ¡IMPORTANTE!

Flex aplica la regla **más larga que coincida**. Si hay empate en longitud, gana la **primera en el archivo**.


| Patrón            | Acción                   | Explicación                                                                                                       |
| ----------------- | ------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| `{separador}`     | `/* omitir */`           | Ignora espacios, tabs y comillas (no retorna nada, el parser nunca los ve)                                        |
| `{constEntera}`   | `return (CONSTENTERA)`   | Retorna token de constante entera al parser                                                                       |
| `":="`            | `return (OPAS)`          | Operador de asignación                                                                                            |
| `"+"`             | `return (MAS)`           | Operador suma                                                                                                     |
| `{identificador}` | `return (IDENTIFICADOR)` | Retorna token de identificador (variable/nombre)                                                                  |
| `"("`             | `return (APAR)`          | Paréntesis abierto                                                                                                |
| `")"`             | `return (CPAR)`          | Paréntesis cerrado                                                                                                |
| `\n`              | `return (NL)`            | Nueva línea (posiblemente usado como delimitador de sentencias)                                                   |
| `.`               | `ECHO`                   | **Cualquier otro carácter**: lo imprime en stdout (útil para depuración o para "pasar" caracteres no reconocidos) |


> **El punto (`.`)**: En regex de Flex, coincide con cualquier carácter **excepto** newline. Como es la última regla, actúa como "catch-all".

---

## 5. Sección de Código de Usuario (vacía aquí)

Después del segundo `%%` puedes poner código C adicional (funciones auxiliares, `main()`, etc.). En este caso está vacío, asumiendo que Bison/Yacc proporcionará el `main()`.

## Ejemplo de Uso

**Entrada:**

```
x := 10 + 20
```

**Tokens generados:**


| Lexema | Token retornado |
| ------ | --------------- |
| `x`    | `IDENTIFICADOR` |
| ``     | *(omitido)*     |
| `:=`   | `OPAS`          |
| ``     | *(omitido)*     |
| `10`   | `CONSTENTERA`   |
| ``     | *(omitido)*     |
| `+`    | `MAS`           |
| ``     | *(omitido)*     |
| `20`   | `CONSTENTERA`   |
| `\n`   | `NL`            |


---

## Posibles Mejoras

1. **El separador incluye comillas**: `([ \t""])+` — ¿Es intencional? Normalmente los separadores son solo `[ \t]+`.
2. **El punto al final**: `. ECHO` imprime caracteres no reconocidos. Para un compilador estricto, debería ser:
  ```flex
   . { fprintf(stderr, "Error léxico: carácter inválido '%c'\n", *yytext); return ERROR; }
  ```

# 2. Explicacion de `sin2.y`

 Este es el archivo de (parser/generador de analizador sintáctico).

---

## 1. Sección de Declaraciones (`%{ ... %}`)

```bison
%{
#include <stdio.h>
#include <stdlib.h>

/* Declaraciones para que el compilador de C moderno no se queje */
int yylex(void);
void yyerror(const char *s);
%}
```


| Elemento                      | Descripción                                                                                     |
| ----------------------------- | ----------------------------------------------------------------------------------------------- |
| `%{ ... %}`                   | Bloque de código C copiado **literalmente** al principio del archivo generado (`y.tab.c`)       |
| `<stdio.h>`                   | Entrada/salida estándar (necesaria para `printf` en `yyerror`)                                  |
| `<stdlib.h>`                  | Biblioteca estándar (buena práctica incluirla)                                                  |
| `int yylex(void)`             | **Declaración explícita** del lexer generado por Flex. Evita warnings del compilador C moderno. |
| `void yyerror(const char *s)` | Declaración de la función de manejo de errores que Bison espera encontrar.                      |


## 2. Declaraciones de Bison (`%token`, `%start`)

```bison
%token IDENTIFICADOR OPAS CONSTENTERA NL MAS APAR CPAR
%start instrucciones
```


| Directiva              | Significado                                                                                                                                 |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `%token`               | Declara **tokens terminales** (símbolos que vienen del lexer). Estos coinciden exactamente con los `return (...)` del archivo `.l` de Flex. |
| `%start instrucciones` | Define el **símbolo inicial** de la gramática. Por defecto es la primera regla, pero aquí se explicita.                                     |


### Tokens declarados (deben coincidir con tu lexer):


| Token en Bison  | Token en Flex            | Lexema ejemplo   |
| --------------- | ------------------------ | ---------------- |
| `IDENTIFICADOR` | `return (IDENTIFICADOR)` | `x`, `variable1` |
| `OPAS`          | `return (OPAS)`          | `:=`             |
| `CONSTENTERA`   | `return (CONSTENTERA)`   | `42`, `123`      |
| `NL`            | `return (NL)`            | `\n`             |
| `MAS`           | `return (MAS)`           | `+`              |
| `APAR`          | `return (APAR)`          | `(`              |
| `CPAR`          | `return (CPAR)`          | `)`              |


> **¡Crítico!** Si los nombres no coinciden exactamente entre Flex y Bison, obtendrás errores de compilación en `y.tab.h`.

---

## 3. Reglas Gramaticales (`%% ... %%`)

```bison
%%

instrucciones : instrucciones instruccion | instruccion;
instruccion : IDENTIFICADOR OPAS expresion NL;
termino : IDENTIFICADOR| CONSTENTERA|APAR expresion CPAR;
expresion : termino | expresion MAS termino;

%%
```

### Análisis de cada regla:

#### **Regla 1: `instrucciones`** (lista de instrucciones)

```bison
instrucciones : instrucciones instruccion | instruccion;
```


| Producción                  | Significado                                                                            |
| --------------------------- | -------------------------------------------------------------------------------------- |
| `instrucciones instruccion` | **Recursión por la izquierda**: una lista de instrucciones seguida de otra instrucción |
| `instruccion`               | **Caso base**: una sola instrucción                                                    |


> **Notación**: `A : B | C` significa "A puede ser B **o** C".

**Árbol de derivación para 2 instrucciones:**

```
instrucciones
├── instrucciones ── instruccion (primera)
└── instruccion (segunda)
```

---

#### **Regla 2: `instruccion`** (asignación)

```bison
instruccion : IDENTIFICADOR OPAS expresion NL;
```


| Componente      | Rol                                    |
| --------------- | -------------------------------------- |
| `IDENTIFICADOR` | Nombre de la variable (lado izquierdo) |
| `OPAS`          | Operador `:=` (asignación)             |
| `expresion`     | Valor a asignar (lado derecho)         |
| `NL`            | Nueva línea (delimitador obligatorio)  |


**Ejemplo que reconoce:** `x := 10 + 5\n`

---

#### **Regla 3: `termino`** (elementos atómicos de expresión)

```bison
termino : IDENTIFICADOR | CONSTENTERA | APAR expresion CPAR;
```


| Alternativa           | Significado                                          |
| --------------------- | ---------------------------------------------------- |
| `IDENTIFICADOR`       | Variable como término                                |
| `CONSTENTERA`         | Número como término                                  |
| `APAR expresion CPAR` | **Expresión entre paréntesis** (permite anidamiento) |


**Ejemplos válidos:**

- `x` → identificador
- `42` → constante
- `(a + b)` → expresión parentizada

---

#### **Regla 4: `expresion`** (expresiones aritméticas)

```bison
expresion : termino | expresion MAS termino;
```


| Producción              | Significado                                         |
| ----------------------- | --------------------------------------------------- |
| `termino`               | Caso base: un término simple                        |
| `expresion MAS termino` | **Recursión por la izquierda**: suma de expresiones |


> **Asociatividad**: Al usar recursión por la izquierda, la suma es **asociativa por la izquierda**: `a + b + c` se parsea como `((a + b) + c)`.

**Jerarquía de la gramática:**

```
instrucciones (lista)
└── instruccion (asignación)
    └── expresion (suma)
        └── termino (átomo o parentizado)
```

---

## 4. Funciones de Soporte en C

```bison
%%

/* Función de error al estilo C moderno (ANSI C) */
void yyerror(const char *s) {
    printf("%s\n", s);
}

/* El main ahora devuelve un entero, como exige el estándar C */
int main(void) {
    yyparse();
    return 0;
}
```


| Función                  | Propósito                                                                                                          |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------ |
| `yyerror(const char *s)` | Callback que Bison invoca cuando detecta error sintáctico. Recibe mensaje descriptivo.                             |
| `yyparse()`              | Función generada por Bison que inicia el análisis sintáctico. Llama repetidamente a `yylex()` para obtener tokens. |
| `return 0`               | Indica éxito al sistema operativo (estándar C).                                                                    |


> **Nota**: `yyparse()` retorna 0 si el análisis fue exitoso, 1 si hubo errores.

---

## Flujo de Ejecución Completo

```
┌─────────────┐     llama      ┌─────────────┐     solicita     ┌─────────────┐
│  yyparse()  │ ─────────────→ │   Parser    │ ────────────────→│   yylex()   │
│  (Bison)    │                │  (Bison)    │    tokens        │   (Flex)    │
└─────────────┘                └─────────────┘                  └─────────────┘
       ↑                              │                                │
       │                              ↓                                ↓
       │                       ┌─────────────┐                  ┌───────────────┐
       └───────────────────────│  yyerror()  │                  │  stdin/archivo│
            (si error)         │  (tú la     │                  │   (entrada)   │
                               │  escribes)  │                  └───────────────┘
                               └─────────────┘
```

---

## Ejemplo de Entrada Válida

**Entrada:**

```
x := 5
y := x + 10
z := (x + y) + 20
```

**Derivación paso a paso de la primera línea:**

```
instrucciones
└── instruccion
    ├── IDENTIFICADOR (x)
    ├── OPAS (:=)
    ├── expresion
    │   └── termino
    │       └── CONSTENTERA (5)
    └── NL (\n)
```

---

## Posibles Mejoras

### 2. **Acciones semánticas** (construcción de AST)

```bison
expresion : termino { $$ = $1; }
          | expresion MAS termino { $$ = crear_nodo_suma($1, $3); }
          ;
```

### 3. **Precedencia de operadores** (para futuros operadores `*`, `/`, `-`)

```bison
%left MAS
%left POR   /* Mayor precedencia que MAS */
```

### 4. **Manejo de errores de recuperación**

```bison
instruccion : error NL { yyerrok; }  /* Recuperarse al encontrar nueva línea */
```

