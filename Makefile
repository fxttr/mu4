include mk/Params.mk

.PHONY: all
all: $(IMAGE_NAME).iso

.PHONY: all-hdd
all-hdd: $(IMAGE_NAME).hdd

.PHONY: run
run: $(IMAGE_NAME).iso
	qemu-system-x86_64 -M q35 -m 2G -cdrom $(IMAGE_NAME).iso -boot d

.PHONY: run-debug
run-debug: $(IMAGE_NAME).iso
	qemu-system-x86_64 -M q35 -m 2G -cdrom $(IMAGE_NAME).iso -boot d -no-reboot -no-shutdown -s -S

.PHONY: gdb
gdb: kernel
	gdb "kern/$(IMAGE_NAME).elf" -ex "target remote :1234"

.PHONY: run-hdd
run-hdd: $(IMAGE_NAME).hdd
	qemu-system-x86_64 -M q35 -m 2G -hda $(IMAGE_NAME).hdd

.PHONY: os
os: kernel

.PHONY: kernel
kernel:
	$(MAKE) -C kern

.PHONY: clean
clean:
	$(MAKE) -C kern clean

.PHONY: distclean
distclean: clean
	$(MAKE) -C kern distclean