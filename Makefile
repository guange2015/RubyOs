all: kernel boot
	dd if=boot.bin of=out/a.img bs=512 count=1 conv=notrunc
	sudo mount -o loop out/a.img /mnt/floppy
	sudo rm -fr /mnt/floppy/system
	sudo mkdir /mnt/floppy/system
	sudo cp loader.bin /mnt/floppy/system -v
	sudo umount /mnt/floppy

kernel:
	#nasm loader.asm -o loader.bin
	nasm -f elf loader.asm -o loader.o
	gcc34 -c main.c
	ld -o loader -Ttext 0x100 -N -e main loader.o main.o
	objcopy -R .note -R .comment -S -O binary loader loader.bin

boot:
	nasm boot.asm -o boot.bin
dis:
	ndisasm -o 32 loader.bin

clean:
	rm *.bin *.o loader
