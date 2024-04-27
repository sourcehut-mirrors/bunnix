// Architecture-specific state (registers).
export type context = struct {
	fs: u64,		// 0
	fsbase: u64,		// 8

	r15: u64,		// 16
	r14: u64,		// 24
	r13: u64,		// 32
	r12: u64,		// 40
	r11: u64,		// 48
	r10: u64,		// 56
	r9: u64,		// 64
	r8: u64,		// 72
	rbp: u64,		// 80
	rdi: u64,		// 88
	rsi: u64,		// 96
	rdx: u64,		// 104
	rcx: u64,		// 112
	rbx: u64,		// 120
	rax: u64,		// 128

	intno: u64,		// 136
	errcode: u64,		// 144

	rip: u64,		// 152
	cs: u64,		// 160
	rflags: u64,		// 168
	rsp: u64,		// 176
	ss: u64,		// 184
};				// 192 (end)
