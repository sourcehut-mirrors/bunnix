.text
.extern arch.main.main

.globl _start
_start:
	/* Move the stack into the higher half and reset the frame pointer */
	mov $_kernel_stack_top, %rsp
	subq $8, %rsp
	xor %rbp, %rbp
	jmp arch.main.main

.type _start, @function
.size _start, .-_start
