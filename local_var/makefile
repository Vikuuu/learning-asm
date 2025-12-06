local: local.o
	ld -o local local.o
local.o: local.asm
	nasm -f elf64 -g -F dwarf local.asm
