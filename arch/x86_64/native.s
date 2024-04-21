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
