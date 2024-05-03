use arch;
use mman;

let @symbol("_kernel_stack_top") _kernel_stack_top: [*]u8;

let idle: *arch::context = null: *arch::context;

fn switch_idle() never = {
	arch::set_kernel_stack(&_kernel_stack_top);
	mman::vmm_map(&mman::kernel);
	arch::getcpu().task = idle;
	arch::idle();
};

fn is_idle() bool = {
	return arch::getcpu().task == idle;
};
