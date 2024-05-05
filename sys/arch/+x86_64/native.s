.text

.global arch.pause
arch.pause:
	pause
	ret

.global arch.idle
arch.idle:
	movq $_kernel_stack_top, %rsp
	sti
_idle:
	hlt
	jmp _idle

.text
.global rt.fetch_add
rt.fetch_add:
	lock xadd %rsi, (%rdi)
	mov %rsi, %rax
	ret

.global rt.barrier
rt.barrier:
	mfence
	ret
