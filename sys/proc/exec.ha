use arch;
use errors::{error, errno};
use mman;
use io;

// Loads an image into a process and executes it.
//
// Does not return on success.
export fn exec(
	proc: *proc,
	file: *io::file,
	args: []str,
) (void | error) = {
	let new_vmm = mman::vmm { ... };
	mman::vmm_init(&new_vmm)?;
	defer io::unref(file);

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

	let task = proc.task;
	arch::context_set_sp(&task.state, STACK_TOP);
	arch::context_set_ip(&task.state, ip);
	arch::enter_user(&task.state);
};
