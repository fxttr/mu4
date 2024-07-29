// Copyright (C) 2024 Florian Marrero Liestmann
// SPDX-License-Identifier:  GPL-3.0-only

// See: https://refspecs.linuxbase.org/elf/gabi4+/ch4.eheader.html
// We only support 64 Bit.

// The Magic number is "0x7F"(EI_MAG0) followed by 45 (EI_MAG1 = E) 4c (EI_MAG2 = L) 46 (EI_MAG3 = F)
// Size: 4 bytes
#define EI_MAG0 0x7F
#define EI_MAG1 0x45
#define EI_MAG2 0x4c
#define EI_MAG3 0x46

// Size of the identification header
#define EI_NIDENT 16

// Values for program_header type
#define ELF_PROG_LOAD 1

// Flag bits for program_header flags
#define ELF_PROG_FLAG_EXEC 1
#define ELF_PROG_FLAG_WRITE 2
#define ELF_PROG_FLAG_READ 4

// File header
struct elf_header {
	unsigned char e_ident[EI_NIDENT]; // 16 bytes
	unsigned short e_type;
	unsigned short e_machine;
	unsigned int e_version;
	unsigned int e_entry;
	unsigned int e_phoff;
	unsigned int e_shoff;
	unsigned int e_flags;
	unsigned short e_ehsize;
	unsigned short e_phentsize;
	unsigned short e_phnum;
	unsigned short e_shentsize;
	unsigned short e_shnum;
	unsigned short e_shstrndx;
};

// See: https://refspecs.linuxbase.org/elf/gabi4+/ch5.pheader.html

// Program section header
struct program_header {
	unsigned int p_type;
	unsigned int p_flags;
	unsigned int p_offset;
	unsigned int p_vaddr;
	unsigned int p_paddr;
	unsigned int p_filesz;
	unsigned int p_memsz;
	unsigned int p_align;
};

inline unsigned int is_elf(struct elf_header *header)
{
	return header->e_ident[0] == EI_MAG0 && header->e_ident[1] == EI_MAG1 &&
	       header->e_ident[2] == EI_MAG2 && header->e_ident[3] == EI_MAG3;
}