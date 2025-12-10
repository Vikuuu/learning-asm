eatmacro: eatmacro.o
	ld -o eatmacro eatmacro.o
eatmacro.o: eatmacro.asm
	nasm -f elf64 -g -F dwarf eatmacro.asm
