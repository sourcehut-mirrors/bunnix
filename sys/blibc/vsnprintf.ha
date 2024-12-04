use fmt;
use io;
use memio;
use types::c;

export @symbol("vsnprintf") fn vsnprintf(
	string: *c::char,
	sz: size,
	fmt: const *c::char,
	ap: valist,
) int = {
	// XXX: This aborts if sz < n
	// It's only used by libvterm for which this is never untrue
	assert(string != null);

	let string = string: *[*]u8;
	let fmt = (fmt: *[*]u8)[..c::strlen(fmt)];
	let out = memio::fixed(string[..sz]);

	let n = 0z;
	for (let i = 0z; i < len(fmt); i += 1) {
		const rn = fmt[i];
		if (rn != '%') {
			io::write(&out, [rn])!;
			n += 1;
			continue;
		};

		i += 1;
		rn = fmt[i];
		switch (rn) {
		case 's' =>
			const arg = vaarg(ap, const *c::char);
			n += fmt::fprint(&out, c::tostr_unsafe(arg))!;
		case 'd' =>
			const arg = vaarg(ap, int);
			n += fmt::fprint(&out, arg)!;
		case 'c' =>
			const arg = vaarg(ap, c::uchar);
			n += fmt::fprint(&out, arg: u32: rune)!;
		case =>
			abort();
		};
	};

	if (n < sz) {
		string[n] = 0;
	};
	return n: int;
};
