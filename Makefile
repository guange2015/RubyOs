all:
	nasm boot.asm -o boot.bin
	nasm loader.asm -o loader.bin
	dd if=boot.bin of=out/a.img bs=512 count=1 conv=notrunc
	sudo mount -o loop out/a.img /mnt/floppy
	sudo rm -fr /mnt/floppy/system
	sudo mkdir /mnt/floppy/system
	sudo cp loader.bin /mnt/floppy/system -v
	sudo umount /mnt/floppy
