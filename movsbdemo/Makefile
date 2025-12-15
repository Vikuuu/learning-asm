movsbdemo: movsbdemo.o
	ld -o movsbdemo movsbdemo.o
movsbdemo.o: movsbdemo.asm
	nasm -f elf64 -g -F dwarf movsbdemo.asm

run:
	./movsbdemo
