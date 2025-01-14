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
	io::seek(file, 0, io::whence::SET)?;

	// Stash these in the kernel heap before switching vmms
	// XXX: This is probably avoidable if we were clever
	const args = strings::dupall(args);
	const env = strings::dupall(env);
	defer strings::freeall(env);

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

	populate_argv(proc, args, env)!;

	if (len(proc.tasks) == 0) {
		let task = sched::newtask(&proc.vmm, proc)!;
		append(proc.tasks, task)!;
	};

	// Note: exec cannot fail beyond this point

	for (let fd &.. proc.fds) {
		if (fd.file == null) {
			continue;
		};
		if (fd.oflag & io::flag::CLOEXEC == 0) {
			continue;
		};
		io::unref(fd.file as *io::file);
		fd.file = null;
	};

	mman::vmm_finish(&old_vmm);

	// Clear out old threads
	for (len(proc.tasks) > 1) {
		sched::task_finish(proc.tasks[1]);
		delete(proc.tasks[1]);
	};

	proc.sig = sigproc { ... };
	proc.args = args;

	let task = proc.tasks[0];
	arch::context_set_sp(&task.ctx, STACK_TOP);
	arch::context_set_ip(&task.ctx, ip);
	sched::task_activate(task);
	sched::enter_user(task);
};

fn populate_argv(proc: *proc, args: []str, env: []str) (void | error) = {
	let vecsz = 0z;
	let datasz = 0z;
	let vmm = &proc.vmm;

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

	vecsz += size(elf::auxv64); // AT_PAGESZ
	vecsz += size(elf::auxv64); // AT_UID
	vecsz += size(elf::auxv64); // AT_EUID
	vecsz += size(elf::auxv64); // AT_GID
	vecsz += size(elf::auxv64); // AT_EGID
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
	vi += 1;

	let auxv = &vector[vi]: *[*]elf::auxv64;
	auxv[0] = elf::auxv64 {
		a_type = elf::at::PAGESZ,
		a_val = arch::PAGESIZE: u64,
	};
	auxv[1] = elf::auxv64 {
		a_type = elf::at::UID,
		a_val = proc.creds.uid: u64,
	};
	auxv[2] = elf::auxv64 {
		a_type = elf::at::EUID,
		a_val = proc.creds.euid: u64,
	};
	auxv[3] = elf::auxv64 {
		a_type = elf::at::GID,
		a_val = proc.creds.gid: u64,
	};
	auxv[4] = elf::auxv64 {
		a_type = elf::at::EGID,
		a_val = proc.creds.egid: u64,
	};
	auxv[2] = elf::auxv64 {
		a_type = elf::at::NULL,
		a_val = 0,
	};
};
