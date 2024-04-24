use types::c;
use log;

export type FILE = opaque;

// stub
export @symbol("fflush") fn fflush(stream: nullable *FILE) int = {
	return 0;
};

// stub
export @symbol("puts") fn puts(s: const *c::char) int = {
	return log::println(c::tostr_unsafe(s)): int;
};
