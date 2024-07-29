// Copyright (C) 2024 Florian Marrero Liestmann
// SPDX-License-Identifier:  GPL-3.0-only

#define KERNEL_BASE_ADDRESS 0x80000000
#define V2P(x) \
	(((unsigned int)(x)) - KERNEL_BASE_ADDRESS) // Virtual to physical
#define P2V(x) \
	((void *)(((char *)(x)) + KERNEL_BASE_ADDRESS)) // Physical to virtual

#define PHYSICAL_MEMORY_TOP 0xE000000
#define EXTEND_MEMORY 0x100000
#define KERNEL_LINK_ADDRESS (KERNEL_BASE_ADDRESS + EXTEND_MEMORY)

#define DEVICE_SPACE 0xFE000000