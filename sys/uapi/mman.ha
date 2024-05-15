use errors::{error, errno};
use mman;
use proc;

fn sys_mmap(opts: *mmap_options) (u64 | error) = {
	validate_user_addr(opts, size(mmap_options), false)?;

	const flag = opts.flags: mman::flag & mman::flag::USER_MASK;
	assert(flag & mman::flag::ANON != 0); // TODO

	const vmm = &proc::current().vmm;
	const uptr = mman::mmap(
		vmm,
		0,
		opts.addr: uintptr,
		opts.length,
		opts.prot: mman::prot,
		flag | mman::flag::USER,
	)?;
	return uptr: u64;
};

fn sys_munmap(addr: *opaque, length: size) (u64 | error) = {
	const vmm = &proc::current().vmm;
	mman::munmap(vmm, addr: uintptr, length)?;
	return 0u64;
};

fn sys_mprotect(addr: *opaque, length: size, prot: int) (u64 | error) = {
	const vmm = &proc::current().vmm;
	// TODO: validate address is in lower half
	mman::mprotect(vmm, addr: uintptr, length, prot: mman::prot)?;
	return 0u64;
};

fn sys_brk(addr: uintptr) (u64 | error) = {
	const cur = proc::current();
	return mman::brk(&cur.vmm, addr)?: u64;
};
