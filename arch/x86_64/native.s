.text

.globl arch.x86_64.rdmsr
arch.x86_64.rdmsr:
	mov %edi, %ecx
	rdmsr
	shl $32, %rdx
	or %rdx, %rax
	ret

.globl arch.x86_64.wrmsr
arch.x86_64.wrmsr:
	mov %edi, %ecx
	mov %esi, %eax
	mov %rsi, %rdx
	shr $32, %rdx
	wrmsr
	ret

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

.globl arch.x86_64._lgdt
arch.x86_64._lgdt:
	lgdt (%rdi)
	ret

.globl arch.x86_64.ltr
arch.x86_64.ltr:
	ltr %di
	ret

.globl arch.x86_64.lidt
arch.x86_64.lidt:
	lidt (%rdi)
	ret

.globl arch.x86_64.lseg
arch.x86_64.lseg:
	movw %di, %fs
	movw %di, %gs
	ret
