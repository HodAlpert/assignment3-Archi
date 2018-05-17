# all: sic.o
# 	gcc -g -Wall -o sic sic.o

# sic.o: sic.s
# 	nasm -g -f elf64 -w+all -o sic.o sic.s

all: main.o
	gcc -g -Wall -o sic main.o

main.o: main.c
	gcc -g -Wall -c -o main.o main.c

.PHONY: clean

clean:
	rm -f *.o sic
