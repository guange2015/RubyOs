CCOMPILE=cc
ASM_COMPILE=nasm
##CFLAGS=-nostdlib -nostdinc -fno-builtin -Wall -fstrength-reduce -fomit-frame-pointer -finline-functions -fno-align-functions -falign-jumps=1  -fno-stack-protector
CFLAGS=-nostdlib -nostdinc -fno-builtin -fno-stack-protector

all: kernel boot
	dd if=boot.bin of=out/a.img bs=512 count=1 conv=notrunc
	sudo mount -o loop out/a.img /mnt/floppy
	sudo rm -fr /mnt/floppy/*	
	sudo cp LOADER.BIN /mnt/floppy/ -v
	sudo cp KERNEL.BIN /mnt/floppy/ -v
	sudo umount /mnt/floppy

kernel:
	${ASM_COMPILE} loader.asm -o LOADER.BIN
#	${ASM_COMPILE} kernel.asm -o KERNEL.BIN
	${CCOMPILE}  ${CFLAGS} -c test.c	
	${CCOMPILE}  ${CFLAGS} -c kprintf.c
	${CCOMPILE}  ${CFLAGS} -c monitor.c
	ld -Ttext 0x30400 -s test.o kprintf.o monitor.o -e main -o KERNEL.BIN
#	nasm -f elf loader.asm -o loader.o
#	gcc34 -c main.c
#	ld -o loader -Ttext 0x100 -N -e main loader.o main.o
#	objcopy -R .note -R .comment -S -O binary loader loader.bin

boot:
	${ASM_COMPILE} boot.asm -o boot.bin
	
dis:
#	ndisasm -o 32 KERNEL.BIN
	objdump -D KERNEL.BIN
	

clean:
	rm *.bin *.o *.BIN
