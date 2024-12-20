; Copyright (c) 2024, Jayden Grubb <contact@jaydengrubb.com>
; SPDX-License-Identifier: BSD-3-Clause

%define VIRT_BASE 0xffffffff80000000

extern kmain

section .multiboot
header_start:
	align 8
	dd 0xe85250d6					; multiboot2 magic number
	dd 0							; architecture
	dd header_end - header_start	; header length

	; checksum
	dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

	; end tag
	align 8
	dw 0
	dw 0
	dd 8
header_end:


; Reserve 12 KiB of memory for the initial page tables
section .page_tables
align 4096

l4_page_table:
	resb 8 * 512
l3_page_table:
	resb 8 * 512
l2_page_table:
	resb 8 * 512


; Reserve 16 KiB of memory for the stack
section .stack
align 4096

stack_top:
	resb 1024 * 16
stack_bottom:


; Define the GDT, base and limit fields are ignored in 64-bit
; mode, so only the access and flags fields are used
; 0x0000000000000000	->	Zero entry (always required)
; 0x0020980000000000	->	Kernel code segment
; 0x0020930000000000	->	Kernel data segment
; 0x0020f80000000000	->	User code segment
; 0x0020f20000000000	->	User data segment
section .rodata
align 4096

global gdt
gdt:
	dq 0												; Zero entry
.kcode: equ $ - gdt
	dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53)	; Kernel code segment entry
	; executable, code/data type, present, 64-bit
.kdata: equ $ - gdt
	dq (1 << 41) | (1 << 44) | (1 << 47) | (1 << 53)	; Kernel data segment entry
	; writeable, code/data type, present, 64-bit
.ucode: equ $ - gdt
	dq (1 << 43) | (1 << 44) | (3 << 45) | (1 << 47) | (1 << 53)	; User code segment entry
	; executable, code/data type, user mode, present, 64-bit
.udata: equ $ - gdt
	dq (1 << 41) | (1 << 44) | (3 << 45) | (1 << 47) | (1 << 53)	; User data segment entry
	; writeable, code/data type, user mode, present, 64-bit
.tss: equ $ - gdt
	resb 16	; Task state segment entry (filled programmatically later in boot process)
.pointer:				; Value used by LGDT
	dw $ - gdt - 1		; Length of GDT
	dq gdt - VIRT_BASE	; Address of GDT


section .text
bits 32

global main_entry
main_entry:
	; Disable interrupts
	cli

	; Set the stack pointer
	mov esp, stack_top - VIRT_BASE

	; Move magic number and pointer to arguement registers
	mov esi, ebx
	mov edi, eax

	; Do CPU checks
	call check_multiboot
	call check_cpuid
	call check_ext_cpu_info
	call check_long_mode

	; Setup and enable paging (1 GiB identity mapped)
	call init_pages
	call enable_pages

	; Load GDT and jump to 64-bit code
	lgdt [gdt.pointer - VIRT_BASE]
	jmp gdt.kcode:(long_mode_entry - VIRT_BASE)

	; Output error 0x00 (Unexpected Kernel Exit)
	mov al, 0
	jmp output_error


; Halt the OS and loop if escapes
terminate:
	cli
	hlt
	jmp terminate


; Initializes the page tables with the first
; 1 GiB of memory identity mapped
init_pages:
	; Recursively map level 4 page table
	mov eax, l4_page_table - VIRT_BASE
	or eax, 0b11	; writeable, present
	mov [l4_page_table - VIRT_BASE + 8 * 510], eax	; Recursive map

	; Setup level 4 page table
	mov eax, l3_page_table - VIRT_BASE
	or eax, 0b11	; writeable, present
	mov [l4_page_table - VIRT_BASE], eax			; Lower-half identity map
	mov [l4_page_table - VIRT_BASE + 8 * 511], eax	; Higher-half identity map

	; Setup level 3 page table
	mov eax, l2_page_table - VIRT_BASE
	or eax, 0b11	; writeable, present
	mov [l3_page_table - VIRT_BASE], eax			; Lower-half identity map
	mov [l3_page_table - VIRT_BASE + 8 * 510], eax	; Higher-half identity map

	; Setup 512 level 2 huge page tables
	mov ecx, 0
.loop:
	mov eax, 0x200000	; 2MiB
	mul ecx
	or eax, 0b10000011	; huge page, writeable, present
	mov [l2_page_table - VIRT_BASE + ecx * 8], eax
	inc ecx
	cmp ecx, 512
	jne .loop
	ret


; Enable paging with page table initialized in init_pages
enable_pages:
	; Set page table location
	mov eax, l4_page_table - VIRT_BASE
	mov cr3, eax

	; Enable physical address extension (PAE)
	mov eax, cr4
	or eax, 1 << 5
	mov cr4, eax

	; Enable long mode
	mov ecx, 0xC0000080
	rdmsr
	or eax, 1 << 8
	wrmsr

	; Enable paging
	mov eax, cr0
	or eax, 1 << 31
	mov cr0, eax

	ret


; Outputs the error code in the AL register
output_error:
	out 0x80, al	; POST code output
	add al, 0x30				; Add ASCII value for '0'
	mov byte [0xb800e], al		; ASCII value
	mov byte [0xb800f], 0x1F	; White on blue
	jmp terminate


; Checks if the multiboot header is present
check_multiboot:
	cmp eax, 0x36d76289
	jne .no_multiboot
	ret
.no_multiboot:
	; Output error 0x01 (No Multiboot Present)
	mov al, 0x01
	jmp output_error


; Checks if the CPUID instruction is available
check_cpuid:
	pushfd
	pop eax
	mov ecx, eax
	xor eax, 1 << 21
	push eax
	popfd
	pushfd
	pop eax
	push ecx
	popfd
	cmp eax, ecx
	je .no_cpuid
	ret
.no_cpuid:
	; Output error 0x02 (No CPUID Instruction)
	mov al, 0x02
	jmp output_error


; Checks if extended CPU info is supported
check_ext_cpu_info:
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001
	jb .no_ext_info
	ret
.no_ext_info:
	; Output error 0x03 (No Extended CPU Info)
	mov al, 0x03
	jmp output_error


; Check if the CPU supports long mode
check_long_mode:
	mov eax, 0x80000001
	cpuid
	test edx, 1 << 29
	jz .no_long_mode
	ret
.no_long_mode:
	; Output error 0x04 (No Long Mode)
	mov al, 0x04
	jmp output_error


section .text
bits 64
long_mode_entry:
	; Sets all data segment registers
	mov ax, gdt.kdata
	mov ss, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	; Update GDT pointer to use higher-half address
	lea rax, gdt
	mov [gdt.pointer + 2], rax

	; Reload GDT in long mode
	lgdt [gdt.pointer]
	lea rax, high_mem_entry
	jmp rax

	jmp terminate


high_mem_entry:
	; Reset stack pointers
	mov rsp, stack_top
	xor rbp, rbp

	; Unmap lower-half identity mapping
	mov rax, 0
	mov [l4_page_table], rax
	mov rax, cr3
	mov cr3, rax

	; Finally, go to main kernel function
	call kmain

	jmp terminate
