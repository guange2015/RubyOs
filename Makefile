CCOMPILE=gcc34
ASM_COMPILE=nasm
##CFLAGS=-nostdlib -nostdinc -fno-builtin -Wall -fstrength-reduce -fomit-frame-pointer -finline-functions -fno-align-functions -falign-jumps=1  -fno-stack-protector
#CFLAGS=-nostdlib -nostdinc -fno-builtin -fno-stack-protector
CFLAGS=-nostdlib -nostdinc -fno-builtin
LINKFLAGS = -Tlink.lds

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
	${CCOMPILE}  ${CFLAGS} -c desc_idt.c
	${CCOMPILE}  ${CFLAGS} -c msr.c
	${CCOMPILE}  ${CFLAGS} -c common.c
	${CCOMPILE}  ${CFLAGS} -c timer.c
	${ASM_COMPILE} -felf isr.asm
	${ASM_COMPILE} -felf irq.asm
	ld ${LINKFLAGS}  -s test.o kprintf.o monitor.o desc_idt.o isr.o msr.o common.o irq.o timer.o -e main -o KERNEL.BIN -Map kernel.map
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
