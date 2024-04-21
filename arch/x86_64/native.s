.text
.globl arch.x86_64.wrcr3
arch.x86_64.wrcr3:
	mov %rdi, %cr3
	ret

.globl arch.x86_64.rdcr3
arch.x86_64.rdcr3:
	mov %cr3, %rax
	ret

.globl arch.x86_64.invlpg
arch.x86_64.invlpg:
	invlpg (%rdi)
	ret

.global arch.x86_64.outb
arch.x86_64.outb:
	mov %di, %dx
	mov %sil, %al
	outb %al, %dx
	ret

.global arch.x86_64.inb
arch.x86_64.inb:
	mov %di, %dx
	inb %dx, %al
	ret

.global arch.x86_64.outw
arch.x86_64.outw:
	mov %di, %dx
	mov %si, %ax
	outw %ax, %dx
	ret

.global arch.x86_64.inw
arch.x86_64.inw:
	mov %di, %dx
	inw %dx, %ax
	ret

.global arch.x86_64.outl
arch.x86_64.outl:
	mov %di, %dx
	mov %esi, %eax
	outl %eax, %dx
	ret

.global arch.x86_64.inl
arch.x86_64.inl:
	mov %di, %dx
	inl %dx, %eax
	ret
