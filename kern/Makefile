include ../mk/Params.mk

OBJ = main.o

.PHONY: all
all: bootloader
	echo "hit kern"

bootloader: arch/$(ARCH)/boots1.S arch/$(ARCH)/boots2.c
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c arch/$(ARCH)/boots1.S
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c arch/$(ARCH)/boots2.c
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o bootloader.o boots1.o boots2.o
	$(OBJDUMP) -S bootloader.o > bootloader
	$(OBJCOPY) -S -O binary -j .text bootloader.o bootloader
	../tools/mkbootloader.pl bootloader

.PHONY: clean
clean:
	rm -rf $(IMAGE_NAME).elf *.o bootloader

.PHONY: distclean
distclean: clean