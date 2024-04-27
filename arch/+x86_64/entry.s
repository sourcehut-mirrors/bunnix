// Kernel entry points - exceptions, interrupts, and syscalls
// License: GPL-3.0-only
// License: NCSA
// (c) 2021 K. Lange <klange@toaruos.org>
// (c) 2022 Drew DeVault <sir@cmpwn.com>
.text

.macro IRQ index byte
	.global arch._irq\index
	.type arch._irq\index, @function
	arch._irq\index:
		pushq $0
		pushq $\byte
		jmp isr_common
.endm

.macro ISR_NOERR index
	.global arch._isr\index
	.type arch._isr\index, @function
	arch._isr\index:
		pushq $0
		pushq $\index
		jmp isr_common
.endm

.macro ISR_ERR index
	.global arch._isr\index
	.type arch._isr\index, @function
	arch._isr\index:
		pushq $\index
		jmp isr_common
.endm

// Interrupt Requests
ISR_NOERR 0
ISR_NOERR 1
//ISR_NOERR 2
ISR_NOERR 3
ISR_NOERR 4
ISR_NOERR 5
ISR_NOERR 6
ISR_NOERR 7
ISR_ERR 8
ISR_NOERR 9
ISR_ERR 10
ISR_ERR 11
ISR_ERR 12
ISR_ERR 13
ISR_ERR 14
ISR_NOERR 15
ISR_NOERR 16
ISR_NOERR 17
ISR_NOERR 18
ISR_NOERR 19
ISR_NOERR 20
ISR_NOERR 21
ISR_NOERR 22
ISR_NOERR 23
ISR_NOERR 24
ISR_NOERR 25
ISR_NOERR 26
ISR_NOERR 27
ISR_NOERR 28
ISR_NOERR 29
ISR_NOERR 30
ISR_NOERR 31
IRQ 0, 32
IRQ 1, 33
IRQ 2, 34
IRQ 3, 35
IRQ 4, 36
IRQ 5, 37
IRQ 6, 38
IRQ 7, 39
IRQ 8, 40
IRQ 9, 41
IRQ 10, 42
IRQ 11, 43
IRQ 12, 44
IRQ 13, 45
IRQ 14, 46
IRQ 15, 47

.global arch._isr2
.type arch._isr2, @function
arch._isr2:
	cli
1:
	hlt
	jmp 1b

.macro _swapgs
	cmpq $8, 24(%rsp)
	je 1f
	swapgs
1:
.endm

.extern arch.isr_handler
.type arch.isr_handler, @function

.global isr_common
isr_common:
	_swapgs
	push %rax
	push %rbx
	push %rcx
	push %rdx
	push %rsi
	push %rdi
	push %rbp
	push %r8
	push %r9
	push %r10
	push %r11
	push %r12
	push %r13
	push %r14
	push %r15

	// TODO: fs/fsbase
	push $0
	push $0

	cld

	mov %rsp, %rdi
	call arch.isr_handler
_isr_exit:
	mov %rax, %rsp

	// TODO: fs/fsbase
	pop %r15
	pop %r15

	pop %r15
	pop %r14
	pop %r13
	pop %r12
	pop %r11
	pop %r10
	pop %r9
	pop %r8
	pop %rbp
	pop %rdi
	pop %rsi
	pop %rdx
	pop %rcx
	pop %rbx
	pop %rax

	_swapgs

	// Clean up error code and interrupt #
	add $16, %rsp

	iretq

.global arch.isr_return
.type arch.isr_return,@function
arch.isr_return:
	mov %rdi, %rax
	jmp _isr_exit

// TODO: Fix this up a bit
// - Only save/restore ABI registers
// - Use separate kernel stack
// - Return from syscall/enteruser without _isr_return
.globl arch.syscall
arch.syscall:
	movq %r11, -24(%rsp)	/* %rflags */
	movq %rcx, -40(%rsp)	/* %rip */
	movq (_kernel_stack_top - 8), %rcx
	movq %rcx, -16(%rsp)	/* %rsp */
	movq %ss, %rcx
	movq %rcx, -8(%rsp)	/* %ss */
	movq %cs, %rcx
	movq %rcx, -32(%rsp)	/* %cs */
	subq $56, %rsp

	swapgs
	push %rax
	push %rbx
	push %rcx
	push %rdx
	push %rsi
	push %rdi
	push %rbp
	push %r8
	push %r9
	push %r10
	push %r11
	push %r12
	push %r13
	push %r14
	push %r15

	// TODO: deal with fs/fsbase
	push $0
	push $0

	// ABI fixup
	movq %r10, %rcx
	movq %r8, %r9
	movq %rcx, %r8
	movq %rdx, %rcx
	movq %rsi, %rdx
	movq %rdi, %rsi
	movq %rax, %rdi

	call uapi.syscall

	// TODO: fs/fsbase
	pop %r15
	pop %r15

	pop %r15
	pop %r14
	pop %r13
	pop %r12
	addq $32, %rsp
	pop %rbp
	addq $32, %rsp
	pop %rbx
	addq $8, %rsp
	swapgs

	addq $16, %rsp
	popq %rcx
	addq $8, %rsp
	popq %r11
	popq %r10
	movq %r10, %rsp
	sysretq
