.text
.global time.rdtsc
time.rdtsc:
	xorq %rax, %rax
	rdtsc
	shl $32, %rdx
	orq %rdx, %rax
	ret
