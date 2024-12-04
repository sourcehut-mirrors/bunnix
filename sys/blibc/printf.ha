use log;
use types::c;

export @symbol("printf") fn printf(format: *const c::char, ...) int = {
	let fmt = (format: *[*]u8)[..c::strlen(format)];

	let ap = vastart();
	defer vaend(ap);
	let n = 0z;
	for (let i = 0z; i < len(fmt); i += 1) {
		const rn = fmt[i];
		if (rn != '%') {
			log::print(rn: rune);
			n += 1;
			continue;
		};

		i += 1;
		rn = fmt[i];
		switch (rn) {
		case 's' =>
			const arg = vaarg(ap, const *c::char);
			n += log::print(c::tostr_unsafe(arg));
		case 'd' =>
			const arg = vaarg(ap, int);
			n += log::print(arg);
		case =>
			n += log::printf("(%unsupp {})", rn);
		};
	};

	return n: int;
};
