all:
	nasm -f elf -o kernel.o kernel.asm
	gcc34 -c test.c
	ld -o test -Ttext 0x0 -N -e main kernel.o test.o
	objcopy -R .note -R .comment -S -O binary test test.bin
dis:
	ndisasm -b 32 test.bin

clean:
	rm -fr *.bin *.o
