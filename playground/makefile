playground: playground.o
	ld -o playground playground.o
playground.o: playground.asm
	nasm -f elf64 -g -F stabs playground.asm
