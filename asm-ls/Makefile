asmls: asmls.o
	ld -o asmls asmls.o
asmls.o: asmls.asm
	nasm -f elf64 -g -F dwarf asmls.asm
