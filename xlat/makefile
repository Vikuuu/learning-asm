xlat: xlat.o
	ld -o xlat xlat.o
xlat.o: xlat.asm
	nasm -f elf64 -g -F dwarf xlat.asm
