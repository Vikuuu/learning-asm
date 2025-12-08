eatterm: eatterm.o
	ld -o eatterm eatterm.o
eatterm.o: eatterm.asm
	nasm -f elf64 -g -F dwarf eatterm.asm
