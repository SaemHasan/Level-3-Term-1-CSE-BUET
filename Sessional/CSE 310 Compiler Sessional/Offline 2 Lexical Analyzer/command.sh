flex -o out.c lexanalyzer.l
g++ out.c -lfl -o lexout.out
./lexout.out input.txt
