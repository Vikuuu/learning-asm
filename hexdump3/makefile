hexdump3: hexdump3.o textlib.o
	ld -o hexdump3 hexdump3.o textlib.o
hexdump3.o: hexdump3.asm
	nasm -f elf64 -g -F dwarf hexdump3.asm
textlib.o: textlib.asm
	nasm -f elf64 -g -F dwarf textlib.asm

test:
	./hexdump3 < inputfile.txt > outputfile.txt
	bat outputfile.txt

clean:
	rm -f hexdump3 *.o
