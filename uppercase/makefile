uppercase: uppercase.o
	ld -o uppercase uppercase.o
uppercase.o: uppercase.asm
	nasm -f elf64 -g -F dwarf uppercase.asm
