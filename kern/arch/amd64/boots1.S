# Copyright (C) 2024 Florian Marrero Liestmann
# SPDX-License-Identifier:  GPL-3.0-only

#include "mem.h"
#include "mmu.h"

.code16                       # 16-Bit assembly
.globl start
start:
  cli                         # Disable BIOS interrupts

  # Clear segments
  xorw    %ax,%ax
  movw    %ax,%ds             # Data Segment
  movw    %ax,%es             # Extra Segment
  movw    %ax,%ss             # Stack Segment

# Enable A20 Line, because we want more than 1 MiB memory. See: https://wiki.osdev.org/A20_Line
# We just use the fast A20 Gate here.
.La20gate.1:
  # Waiting for the controller, loop if it is still busy...
  inb     $0x64,%al               # Port 0x64 is the keyboard controller (kbc)
  testb   $0x2,%al                # Check if 0x64 is 1 (busy) or 0 (ready)
  jnz     .La20gate.1

  movb    $0xd1,%al               # Load 0xd1 into port 0x64
  outb    %al,$0x64               # Send to controller port

# Fast A20 Gate part 2
.La20gate.2:
  # Again, wait for the controller.
  inb     $0x64,%al
  testb   $0x2,%al
  jnz     .La20gate.2

  movb    $0xdf,%al                   # Load 0xdf into port 0x60
  outb    %al,$0x60                   # Send to data port

  # Switch to protected mode.
  lgdt    gdt_descriptor              # Load gdt
  movl    %cr0, %eax                  # Control register into eax
  orl     $CR0_PE, %eax               # Set Protected Mode Enable Bit in eax
  movl    %eax, %cr0                  # Write back to control register
  ljmp    $(SEG_KCODE<<3), $start_32  # Do a long jump into protected mode

.code32
start_32:
  movw    $(SEG_KDATA<<3), %ax
  movw    %ax, %ds
  movw    %ax, %es
  movw    %ax, %ss
  movw    $0, %ax
  movw    %ax, %fs
  movw    %ax, %gs

  # We want to do the rest in C
  movl    $start, %esp  # Prepare the stack pointer
  call    load_elf

# An exception occurred. This should not happen.
# TODO: Implement propper exception handling down here.
.Lerrloop:
  jmp .

load_elf:
    # elf = (struct elf_header *)0x10000
    movl $0x10000, %eax
    
    # Read 1st page off disk
    pushl $0                  # offset
    pushl $4096               # count
    pushl %eax                # addr
    call readseg
    addl $12, %esp

    # Is this an ELF executable?
    pushl %eax                # elf
    call is_elf
    addl $4, %esp
    testl %eax, %eax
    jz .Lerrloop                 # test !is_elf(elf), jump to error

    # Load each program segment (ignores ph flags)
    movl 28(%eax), %ebx       # elf->e_phoff
    addl %eax, %ebx           # ph = (struct program_header *)((unsigned char *)elf + elf->e_phoff)
    movl 20(%eax), %ecx       # elf->e_phnum
    movl %ebx, %edx           # ph
    imull $32, %ecx, %ecx     # size of all program headers
    addl %ecx, %ebx           # eph = ph + elf->e_phnum

.Lloop:
    cmpl %ebx, %edx
    jge .Ldone

    # pa = (unsigned char *)ph->p_paddr
    movl 8(%edx), %esi        # ph->p_paddr

    # readseg(pa, ph->p_filesz, ph->p_offset)
    pushl 4(%edx)             # ph->p_offset
    pushl 16(%edx)            # ph->p_filesz
    pushl %esi                # pa
    call readseg
    addl $12, %esp

    # test (ph->p_memsz > ph->p_filesz)
    cmpl 20(%edx), 16(%edx)
    jle .Lnext

    # stosb(pa + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz)
    movl 16(%edx), %ecx       # ph->p_filesz
    addl %ecx, %esi           # pa + ph->p_filesz
    movl 20(%edx), %ecx       # ph->p_memsz
    subl 16(%edx), %ecx       # ph->p_memsz - ph->p_filesz
    xorl %eax, %eax           # Zero fill value
    cld
    rep stosb

.Lnext:
    addl $32, %edx            # ph++
    jmp .Lloop

.Ldone:
    # Call the entry point from the ELF header
    movl 24(%eax), %eax       # elf->e_entry
    jmp *%eax                 # entry()

waitdisk:
    .Lwait:
    inb $0xF7, %al
    andb $0xC0, %al
    cmpb $0x40, %al
    jne .Lwait
    ret

readsect:
    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp

    pushl 8(%ebp)             # dst
    call waitdisk
    addl $4, %esp

    movw $0x1F2, %dx
    movb $1, %al              # count = 1
    outb %al, %dx

    movl 12(%ebp), %eax       # offset
    movw $0x1F3, %dx
    outb %al, %dx
    movb %ah, %al
    movw $0x1F4, %dx
    outb %al, %dx
    movb %eax, %al
    movw $0x1F5, %dx
    outb %al, %dx
    shrl $24, %eax
    orb $0xE0, %al
    movw $0x1F6, %dx
    outb %al, %dx

    movw $0x1F7, %dx
    movb $0x20, %al           # cmd 0x20 - read sectors
    outb %al, %dx

    pushl 8(%ebp)             # dst
    call waitdisk
    addl $4, %esp

    movw $0x1F0, %dx
    movl $SECTOR_SIZE / 4, %ecx
    rep insl

    leave
    ret

readseg:
    pushl %ebp
    movl %esp, %ebp
    subl $16, %esp

    movl 8(%ebp), %eax
    movl %eax, -4(%ebp)       # pa
    movl 12(%ebp), %ecx
    addl %eax, %ecx
    movl %ecx, -8(%ebp)       # epa

    movl 16(%ebp), %eax
    movl $SECTOR_SIZE, %ecx
    divl %ecx
    incl %eax                 # offset = (offset / SECTOR_SIZE) + 1
    movl %eax, 16(%ebp)

.Lsegloop:
    movl -4(%ebp), %eax
    cmpl -8(%ebp), %eax
    jge .Lsegdone

    movl 16(%ebp), %eax
    pushl %eax
    movl -4(%ebp), %eax
    pushl %eax
    call readsect
    addl $8, %esp

    addl $SECTOR_SIZE, -4(%ebp)
    incl 16(%ebp)

    jmp .Lsegloop

.Lsegdone:
    leave
    ret

# Global descriptor table
.p2align 2

# 0x8 -> Executable stack
# 0x2 (on executable segment) -> Readable stack 
# 0x2 (on non-executable segment) -> Writeable stack
gdt:
  .word 0, 0
  .byte 0, 0, 0, 0
  .word((0xffffffff >> 12) & 0xffff), (0x0 & 0xffff)
  .byte((0x0 >> 16) & 0xff), (0x90 | (0x8|0x2))
  .byte(0xC0 | ((0xffffffff >> 28) & 0xf)), ((0x0 >> 24) & 0xff)
  .word((0xffffffff >> 12) & 0xffff), (0x0 & 0xffff)
  .byte((0x0 >> 16) & 0xff), (0x90 | 0x2)
  .byte(0xC0 | ((0xffffffff >> 28) & 0xf)), ((0x0 >> 24) & 0xff)

gdt_descriptor:
  .word   (gdt_descriptor - gdt - 1)
  .long   gdt

.equ SECTOR_SIZE, 512