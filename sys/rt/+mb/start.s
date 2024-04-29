.bss
.align 4096
l2pt:
.skip 4096
l3pt:
.skip 4096
l4pt:
.skip 4096
.align 16
stack_bottom:
.skip 16384
stack_top:

.code32
.text
.global _start
.type _start, @function
_start:
	cli
	movl $stack_top, %esp

	pushl $0
	pushl %esp
	pushl $0
	pushl %eax /* Multiboot header magic */
	pushl $0
	pushl %ebx /* Multiboot header pointer */

	mov %bp, 0x4000

	/* Prepare identity mapped page tables */
	movl $l4pt, %edi
	xorl %eax, %eax
	movl $0xC00, %ecx
	rep stosl

	movl $l4pt, %edi
	movl $l3pt, %eax
	orl $(1 | 2), %eax
	movl %eax, (%edi)
	movl %eax, 0xFF8(%edi)

	movl $l3pt, %edi
	movl $l2pt, %eax
	orl $(1 | 2), %eax
	movl %eax, (%edi)
	movl %eax, 0xFF8(%edi)

	movl $(1 | 2 | (1 << 7)), %eax
	movl $0, %ecx
.map_p2:
	movl %eax, l2pt(,%ecx, 8)
	addl $0x200000, %eax
	addl $1, %ecx
	cmpl $512, %ecx
	jb .map_p2

	wbinvd
	mfence

	movl %cr4, %eax
	orl $((1 << 4) | (1 << 5)), %eax /* Enable PSE, PAE */
	movl %eax, %cr4
	movl $l4pt, %edi
	movl %edi, %cr3

	movl $0xC0000080, %ecx
	rdmsr
	/* Enable SCE & LME (ref AMD vol 2 pg. 56) */
	orl $(1 | (1 << 8)), %eax
	wrmsr

	lgdt gdtdesc
	movl %cr0, %eax
	orl $(1 | (1 << 16) | (1 << 31)), %eax /* Enable PE, WP, PG */
	movl %eax, %cr0

	/* Load GDT and jump to long mode */
	lgdt gdtdesc
	ljmp $0x8, $bits64

gdt:
	.set PRESENT,	1 << 7
	.set NOT_SYS,	1 << 4
	.set EXEC,	1 << 3
	.set DC,	1 << 2
	.set RW,	1 << 1
	.set ACCESSED,	1 << 0

	.set GRAN_4K,	1 << 7
	.set SZ_32,	1 << 6
	.set LONG_MODE,	1 << 5
.gdt_null:
	.quad 0
.gdt_code:
	.long 0xFFFF
	.byte 0
	.byte PRESENT | NOT_SYS | EXEC | RW
	.byte GRAN_4K | LONG_MODE | 0xF
	.byte 0
.gdt_data:
	.long 0xFFFF
	.byte 0
	.byte PRESENT | NOT_SYS | RW
	.byte GRAN_4K | SZ_32 | 0xF
	.byte 0
.gdt_tss:
	.long 0x00000068
	.long 0x00CF8900
gdtdesc:
	.word (gdtdesc - gdt - 1)
	.long gdt

.code64
.align 8
bits64:
	cli
	mov $0x10, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	mov %ax, %ss

	pop %rdi
	pop %rsi
	pop %rdx

	xor %rbp, %rbp
	call rt.start
