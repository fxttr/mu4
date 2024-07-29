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
a20gate.1:
  # Waiting for the controller, loop if it is still busy...
  inb     $0x64,%al               # Port 0x64 is the keyboard controller (kbc)
  testb   $0x2,%al                # Check if 0x64 is 1 (busy) or 0 (ready)
  jnz     a20gate.1

  movb    $0xd1,%al               # Load 0xd1 into port 0x64
  outb    %al,$0x64               # Send to controller port

# Fast A20 Gate part 2
a20gate.2:
  # Again, wait for the controller.
  inb     $0x64,%al
  testb   $0x2,%al
  jnz     a20gate.2

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
  call    _main         # Bye

# An exception occurred. This should not happen.
# TODO: Implement propper exception handling down here.
loop:
  jmp     loop

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


