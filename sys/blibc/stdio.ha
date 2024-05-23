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

// stub
export @symbol("fwrite") fn fwrite(
	ptr: const *opaque,
	sz: size,
	nmemb: size,
	out: *FILE,
) int = {
	return nmemb: int;
};

export @symbol("snprintf") fn snprintf(
	string: *c::char,
	sz: size,
	fmt: const *c::char,
	...
) int = {
	let ap = vastart();
	defer vaend(ap);
	return vsnprintf(string, sz, fmt, ap);
};
