use types::c;

export type FILE = opaque;

// XXX Hack
export const stdin: *FILE = 0: uintptr: *FILE;
export const stdout: *FILE = 1: uintptr: *FILE;
export const stderr: *FILE = 2: uintptr: *FILE;

// stub
export @symbol("fflush") fn fflush(stream: nullable *FILE) int = {
	return 0;
};

// stub
export @symbol("printf") fn printf(format: *const c::char, ...) int = {
	return 0;
};

// stub
export @symbol("puts") fn puts(s: const *c::char) int = {
	return 1;
};
