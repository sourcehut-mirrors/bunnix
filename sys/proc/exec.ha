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
	// TODO: Better error handling
	defer io::unref(file);

	io::seek(file, 0, io::whence::SET)?;

	// Stash these in the kernel heap before switching vmms
	// XXX: This is probably avoidable if we were clever
	const args = strings::dupall(args);
	defer free(args);
	const env = strings::dupall(env);
	defer free(env);

	let old_vmm = proc.vmm;
	match (mman::vmm_init(&proc.vmm)) {
	case let err: error =>
		proc.vmm = old_vmm;
		return err;
	case => void;
	};
	mman::vmm_map(&proc.vmm);

	const ip = match (load(&proc.vmm, file)) {
	case let err: error =>
		proc.vmm = old_vmm;
		mman::vmm_map(&proc.vmm);
		return err;
	case let ip: uintptr =>
		yield ip;
	};

	mman::mmap(
		&proc.vmm, 0,
		STACK_TOP - STACK_SIZE: uintptr,
		STACK_SIZE,
		mman::prot::READ | mman::prot::WRITE,
		mman::flag::ANON | mman::flag::USER,
	)!;

	populate_argv(&proc.vmm, args, env)!;

	if (len(proc.tasks) == 0) {
		let task = sched::newtask(&proc.vmm, proc)!;
		append(proc.tasks, task);
	};

	// Note: exec cannot fail beyond this point

	mman::vmm_finish(&old_vmm);

	// Clear out old threads
	for (len(proc.tasks) > 1) {
		sched::task_unlink(proc.tasks[1]);
		delete(proc.tasks[1]);
	};

	let task = proc.tasks[0];
	arch::context_set_sp(&task.ctx, STACK_TOP);
	arch::context_set_ip(&task.ctx, ip);
	sched::task_activate(task);
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
