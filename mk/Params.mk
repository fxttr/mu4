define IFNDEF =
	ifeq ($($1),)
		$1 := $(2)
	endif
endef

# General build properties
IMAGE_NAME = mu4
ARCH = amd64

# Toolchain properties
TOOLCHAIN = # Set this option if you want to use a custom toolchain (for cross compilation for example)
$(eval $(call IFNDEF,TOOLCHAIN,/usr/bin/))
CC = $(TOOLCHAIN)gcc
AS = $(TOOLCHAIN)gas
LD = $(TOOLCHAIN)ld
OBJCOPY = $(TOOLCHAIN)objcopy
OBJDUMP = $(TOOLCHAIN)objdump
