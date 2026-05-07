flex E5.l
gcc lex.yy.c -o lex
./lex < archivo.txt

# Ejecutar con archivo de prueba
# ./normalizador archivo.txt
# ./lex archivo.txt

# O ejecutar en modo interactivo (stdin)
# ./normalizador