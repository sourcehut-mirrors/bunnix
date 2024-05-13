.text
.global arch.save
arch.save:
	leaq 8(%rsp), %rax
	movq %rax, 0(%rdi)	/* %rsp */
	movq %rbp, 8(%rdi)	/* %rbp */
	movq (%rsp), %rax
	movq %rax, 16(%rdi)	/* %rip */
	movq $0xc0000100, %rcx
	rdmsr
	movl %eax, 24(%rdi)
	movl %edx, 28(%rdi)	/* %fsbase */
	movq %rbx, 32(%rdi)	/* %rbx */
	movq %r12, 40(%rdi)	/* %r12 */
	movq %r13, 48(%rdi)	/* %r13 */
	movq %r14, 56(%rdi)	/* %r14 */
	movq %r15, 64(%rdi)	/* %r15 */
	xorq %rax, %rax
	ret

.global arch.restore
arch.restore:
	movq 0(%rdi), %rsp	/* %rsp */
	movq 8(%rdi), %rbp	/* %rbp */
	movl 24(%rdi), %eax
	movl 28(%rdi), %edx
	movq $0xc0000100, %rcx
	wrmsr			/* %fsbase */
	movq 32(%rdi), %rbx	/* %rbx */
	movq 40(%rdi), %r12	/* %r12 */
	movq 48(%rdi), %r13	/* %r13 */
	movq 56(%rdi), %r14	/* %r14 */
	movq 64(%rdi), %r15	/* %r15 */
	movq %rsi, %rax
	jmpq *16(%rdi)		/* %rip */
