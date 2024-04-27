use arch;
use errors::{error, errno};
use mman;
use fs;
use log;

def STACK_SIZE: size = 65536;

// A process in userspace.
export type proc = struct {
	vmm: mman::vmm,
	// TODO: Proper namespace abstraction
	root: *fs::vfs,
	// TODO: Multithreading
	state: arch::context,
};

// Creates a new process.
export fn new_proc(root: *fs::vfs) (*proc | error) = {
	let proc = alloc(proc {
		root = root,
		...
	});
	arch_init(&proc.state);
	return proc;
};

// Loads an image into a process and executes it.
//
// Does not return on success.
export fn exec(
	proc: *proc,
	file: *fs::file,
	args: []str,
) (void | error) = {
	let new_vmm = mman::vmm { ... };
	mman::vmm_init(&new_vmm)?;

	const ip = match (load(&new_vmm, file)) {
	case let err: error =>
		mman::vmm_map(&proc.vmm);
		return err;
	case let ip: uintptr =>
		yield ip;
	};

	match (mman::mmap(
		&new_vmm, 0,
		STACK_TOP - STACK_SIZE: uintptr,
		STACK_SIZE,
		mman::prot::READ | mman::prot::WRITE,
		mman::flag::ANON | mman::flag::USER,
	)) {
	case let err: error =>
		mman::vmm_map(&proc.vmm);
		return err;
	case uintptr => void;
	};

	proc.vmm = new_vmm;
	arch::context_set_sp(&proc.state, STACK_TOP);
	arch::context_set_ip(&proc.state, ip);
	arch::enter_user(&proc.state);
};
