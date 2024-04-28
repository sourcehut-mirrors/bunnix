// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors::{error, errno};

export type teefile = struct {
	file,
	primary: *file,
	secondary: *file,
};

const tee_vtable: vtable = vtable {
	read = &tee_read,
	write = &tee_write,
	...
};

// Creates a file which copies writes and reads into 'sink' after forwarding
// them to the *file 'h'. This file does not need to be closed, and closing
// it will not close the secondary file.
export fn tee(f: *file, sink: *file) teefile = {
	return teefile {
		vtable = &tee_vtable,
		primary = f,
		secondary = sink,
		...
	};
};

fn tee_read(f: *file, buf: []u8) (size | EOF | error) = {
	let f = f: *teefile;
	let z = match (read(f.primary, buf)?) {
	case EOF =>
		return EOF;
	case let z: size =>
		yield z;
	};
	writeall(f.secondary, buf[..z])?;
	return z;
};

fn tee_write(f: *file, buf: const []u8) (size | error) = {
	let f = f: *teefile;
	const z = write(f.primary, buf)?;
	writeall(f.secondary, buf[..z])?;
	return z;
};
