use arch;
use errors::{error, errno};
use proc;
use mman;

// Validates an address from userspace.
fn validate_user_addr(
	addr: *opaque,
	bytes: size,
	write: bool,
	error: errno = errno::FAULT,
) (void | error) = {
	const vmm = &proc::current().vmm;
	if (!mman::isvalid(vmm, addr: uintptr, bytes, write)) {
		return error;
	};
};

fn validate_vectors(
	vec: *[*]vector,
	nvec: u64,
	write: bool,
	error: errno = errno::FAULT,
) (void | error) = {
	validate_user_addr(vec, size(vector) * nvec: size, false, error)?;

	for (let v .. vec[..nvec]) {
		validate_user_addr(v.base, v.count, write, error)?;
	};
};
