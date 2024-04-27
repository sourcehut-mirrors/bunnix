.section .text.rt.syscall
.global rt.syscall
rt.syscall:
	movq %rcx, %r10
	syscall
	ret
