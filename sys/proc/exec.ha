use arch;
use errors::{error, errno};
use format::elf;
use mman;
use io;
use sched;
use strings;

// Loads an image into a process and executes it.
//
// Does not return on success.
export fn exec(
	proc: *proc,
	file: *io::file,
	args: []str,
	env: []str,
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

	populate_argv(&new_vmm, args, env)?;

	// TODO: Clean up old vmm
	proc.vmm = new_vmm;

	// TODO: Clean up old tasks
	delete(proc.tasks[..]);

	let task = sched::newtask(&proc.vmm, proc)!;
	append(proc.tasks, task);
	arch::context_set_sp(&task.ctx, STACK_TOP);
	arch::context_set_ip(&task.ctx, ip);
	arch::enter_user(&task.ctx);
};

fn populate_argv(vmm: *mman::vmm, args: []str, env: []str) (void | error) = {
	let vecsz = 0z;
	let datasz = 0z;

	// Arguments
	vecsz += size(u64); // argc
	for (let i = 0z; i < len(args); i += 1) {
		vecsz += size(u64); // *char
		datasz += len(args[i]) + 1; // data + nul
	};
	vecsz += size(u64); // 0

	for (let i = 0z; i < len(env); i += 1) {
		vecsz += size(u64); // *char
		datasz += len(env[i]) + 1; // data + nul
	};
	vecsz += size(u64); // 0

	// TODO: auxv
	vecsz += size(elf::auxv64); // AT_NULL

	const totalsz = vecsz + datasz;
	const area = mman::mmap(vmm, 0, STACK_TOP, totalsz,
		mman::prot::READ | mman::prot::WRITE,
		mman::flag::ANON | mman::flag::USER)?;
	let vector = area: *[*]u64;
	let data = (area: uintptr + vecsz: uintptr): *[*]u8;

	vector[0] = len(args): size;

	let vi = 1z, di = 0z;
	for (const arg .. args) {
		data[di..di+len(arg)] = strings::toutf8(arg)[..];
		data[di+len(arg)] = 0;
		vector[vi] = &data[di]: uintptr: u64;

		vi += 1;
		di += len(arg) + 1;
	};
	vector[vi] = 0;
	vi += 1;

	for (const env .. env) {
		data[di..di+len(env)] = strings::toutf8(env)[..];
		data[di+len(env)] = 0;
		vector[vi] = &data[di]: uintptr: u64;

		vi += 1;
		di += len(env) + 1;
	};

	vector[vi] = 0;

	// TODO: auxv
	let auxv = &vector[vi]: *[*]elf::auxv64;
	let ai = 0z;
	auxv[ai] = elf::auxv64 {
		a_type = elf::at::NULL,
		a_val = 0,
	};
};
