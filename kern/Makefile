include ../mk/Params.mk

OBJ = main.o

.PHONY: all
all: bootloader
	echo "hit kern"

bootloader: arch/$(ARCH)/boots1.S
	$(CC) -fno-builtin -fno-pic -m32 -nostdinc -Iinclude -c arch/$(ARCH)/boots1.S
#	$(CC) -fno-builtin -fno-pic -m32 -nostdinc -Iinclude -c arch/$(ARCH)/boots2.c
	$(LD) -m elf_i386 -z nodefaultlib -N -e start -Ttext 0x7C00 -o bootloader.o boots1.o boots2.o
	$(OBJDUMP) -S bootloader.o > bootloader
	$(OBJCOPY) -S -O binary -j .text bootloader.o bootloader
	../tools/mkbootloader.pl bootloader

.PHONY: clean
clean:
	rm -rf $(IMAGE_NAME).elf *.o bootloader

.PHONY: distclean
distclean: clean