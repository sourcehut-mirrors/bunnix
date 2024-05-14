use rt;
use strings;
use types::c;

export @symbol("memcpy") fn memcpy(
	dest: *opaque,
	src: const *opaque,
	n: size,
) nullable *opaque = {
	rt::memcpy(dest, src, n);
	return dest;
};

export @symbol("memset") fn memset(
	s: *opaque,
	c: int,
	n: size,
) nullable *opaque = {
	rt::memset(s, c: u8, n);
	return s;
};

export @symbol("memmove") fn memmove(
	dest: *opaque,
	src: const *opaque,
	n: size,
) *opaque = {
	rt::memmove(dest, src, n);
	return dest;
};

export @symbol("memcmp") fn memcmp(
	s1: const *opaque,
	s2: const *opaque,
	n: size,
) int = {
	const a = s1: *[*]u8;
	const b = s2: *[*]u8;
	for (let i = 0z; i < n; i += 1) {
		if (a[i] < b[i]) {
			return -1;
		} else if (a[i] > b[i]) {
			return 1;
		};
	};
	return 0;
};

export @symbol("strlen") fn strlen(s: *const c::char) size = {
	return c::strlen(s);
};

export @symbol("strcmp") fn strcmp(
	s1: const *c::char,
	s2: const *c::char,
) int = {
	return strings::compare(c::tostr_unsafe(s1), c::tostr_unsafe(s2));
};

export @symbol("strncmp") fn strncmp(
	s1: const *c::char,
	s2: const *c::char,
	n: size,
) int = {
	const s1l = c::strlen(s1);
	const s1 = (s1: *[*]u8)[..if (s1l < n) s1l else n];
	const s2l = c::strlen(s2);
	const s2 = (s2: *[*]u8)[..if (s2l < n) s2l else n];

	const s1 = strings::fromutf8_unsafe(s1);
	const s2 = strings::fromutf8_unsafe(s2);
	return strings::compare(s1, s2);
};

export @symbol("strcpy") fn strcpy(
	dest: *c::char,
	src: const *c::char,
) *c::char = {
	const slen = c::strlen(src);
	const d = dest: *[*]u8;
	const s = src: *[*]u8;
	d[..slen] = s[..slen];
	return dest;
};

export @symbol("strncpy") fn strncpy(
	dst: *c::char,
	src: const *c::char,
	dsize: size,
) *c::char = {
	let slen = c::strlen(src);
	if (slen < dsize) {
		slen = dsize;
	};
	const d = dst: *[*]u8;
	const s = src: *[*]u8;
	d[..slen] = s[..slen];
	return dst;
};
