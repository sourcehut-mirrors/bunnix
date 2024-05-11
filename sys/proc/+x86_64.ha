def STACK_TOP: uintptr = 0x7fff80000000;
def STACK_SIZE: size = 65536;

// TODO: Add siginfo et al here
type signal_stack = struct {
	// %rsp
	sigreturn: uintptr,
};
