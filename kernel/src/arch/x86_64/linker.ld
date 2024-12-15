/* Copyright (c) 2024, Jayden Grubb <contact@jaydengrubb.com> */
/* SPDX-License-Identifier: BSD-3-Clause */

OUTPUT_FORMAT(elf64-x86-64)
ENTRY(main_entry)

KERNEL_PHYS = 0x200000;
KERNEL_VIRT = 0xffffffff80000000;

SECTIONS {
	. = KERNEL_PHYS + KERNEL_VIRT;

	.text ALIGN(4K) : AT(ADDR(.text) - KERNEL_VIRT) {
		*(.multiboot)
		*(.text*)
	}

	.rodata ALIGN(4K) : AT(ADDR(.rodata) - KERNEL_VIRT) {
		*(.rodata*)
		. = ALIGN(8);
		*(.ctors)
		*(.init_array)
	}

	.data ALIGN(4K) : AT(ADDR(.data) - KERNEL_VIRT) {
		*(.data*)
	}

	.bss ALIGN(4K) (NOLOAD) : AT(ADDR(.bss) - KERNEL_VIRT) {
		*(COMMON)
		*(.bss*)
		*(.stack)
		*(.page_tables)
	}

	__kernel_end = .;

	/DISCARD/ : {
		*(.note*)
		*(.comment*)
	}
}
