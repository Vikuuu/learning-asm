hexdump: hexdump.o
	ld -o hexdump hexdump.o
hexdump.o: hexdump.asm
	nasm -f elf64 -g -F dwarf hexdump.asm
