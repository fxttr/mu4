define IFNDEF =
	ifeq ($($1),)
		$1 := $(2)
	endif
endef

# General build properties
IMAGE_NAME = mu4
ARCH = amd64
CFLAGS = -fno-pic -static -fno-builtin -fno-strict-aliasing -Wall -MD -ggdb -fno-omit-frame-pointer -fno-stack-protector -ffreestanding -fno-common -nostdlib -Iinclude -gdwarf-2 -m64 -DX64 -mcmodel=kernel -mtls-direct-seg-refs -mno-red-zone
ASFLAGS = -fno-pic -gdwarf-2 -Wa,-divide -Iinclude -m64 -DX64 -mcmodel=kernel -mtls-direct-seg-refs -mno-red-zone
LDFLAGS = -m elf_x86_64 -z nodefaultlib

# Toolchain properties
TOOLCHAIN = # Set this option if you want to use a custom toolchain (for cross compilation for example)
$(eval $(call IFNDEF,TOOLCHAIN,/usr/bin/))
CC = $(TOOLCHAIN)gcc
AS = $(TOOLCHAIN)as
LD = $(TOOLCHAIN)ld
OBJCOPY = $(TOOLCHAIN)objcopy
OBJDUMP = $(TOOLCHAIN)objdump
