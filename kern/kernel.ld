OUTPUT_FORMAT("elf64-x86-64", "elf64-x86-64", "elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)
ENTRY(_start)

mboot_load_addr = 0x00100000;

SECTIONS
{
    /* Must be equal to KERNEL_LINK_ADDRESS */
	. = 0xFFFFFFFF80100000;

	PROVIDE(begin = .);

	.text : AT(mboot_load_addr) {
		*(.text .rela.text .stub .text.* .gnu.linkonce.t.*)
	}

	PROVIDE(etext = .);

	.rodata : {
		*(.rodata .rodata.* .gnu.linkonce.r.*)
	}

	. = ALIGN(0x1000);

	PROVIDE(data = .);

	.data : {
		*(.data)
	}

	. = ALIGN(0x1000);

	PROVIDE(edata = .);

	.bss : {
		*(.bss)
		*(COMMON)
	}

	. = ALIGN(0x1000);

	PROVIDE(end = .);

	/DISCARD/ : {
		*(.eh_frame .rela.eh_frame .note.GNU-stack)
	}
}

mboot_load_end = mboot_load_addr + (edata - begin);
mboot_bss_end = mboot_load_addr + (end - begin);
mboot_entry_addr = mboot_load_addr + (mboot_entry - begin);