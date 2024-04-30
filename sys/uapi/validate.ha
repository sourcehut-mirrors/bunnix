use arch;
use errors::{error, errno};
use proc;
use mman;
use types;

// Validates an address from userspace.
fn validate_user_addr(
	addr: nullable *opaque,
	bytes: size,
	write: bool = false,
	error: errno = errno::FAULT,
) (void | error) = {
	const vmm = &proc::current().vmm;
	if (!mman::isvalid(vmm, addr: uintptr, bytes, write)) {
		return error;
	};
};

fn validate_user_string(
	string: str,
	write: bool = false,
) (void | error) = {
	const string = &string: *types::string;
	if (string.data == null && string.length == 0) {
		return;
	};
	validate_user_addr(string.data, string.length, write)?;
};

fn validate_user_slice(
	slice: []opaque,
	itemsz: size,
	write: bool = false,
) (void | error) = {
	const slice = &slice: *types::slice;
	if (slice.data == null && slice.length == 0) {
		return;
	};
	validate_user_addr(slice.data, slice.length * itemsz, write)?;
};

fn validate_vectors(
	vec: *[*]vector,
	nvec: u64,
	write: bool = false,
	error: errno = errno::FAULT,
) (void | error) = {
	validate_user_addr(vec, size(vector) * nvec: size, false, error)?;

	for (let v .. vec[..nvec]) {
		validate_user_addr(v.base, v.count, write, error)?;
	};
};
