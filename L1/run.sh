#!/bin/bash

bison -yd sin2.y
flex sin2.l
gcc y.tab.c lex.yy.c -o salida
# ./salida < entrada.txt