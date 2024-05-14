use bytes;
use rt;
use sort;

export @symbol("malloc") fn malloc(sz: size) nullable *opaque = {
	return rt::malloc(sz);
};

export @symbol("free") fn _free(ptr: nullable *opaque) void = {
	free(ptr);
};

export @symbol("calloc") fn calloc(nmemb: size, sz: size) nullable *opaque = {
	match (rt::malloc(nmemb * sz)) {
	case let ptr: *opaque =>
		const data = ptr: *[*]u8;
		bytes::zero(data[..nmemb*sz]);
		return ptr;
	case null =>
		return null;
	};
};

export @symbol("realloc") fn realloc(ptr: nullable *opaque, sz: size) nullable *opaque = {
	return rt::realloc(ptr, sz);
};

export @symbol("qsort") fn qsort(
	base: *opaque,
	nmemb: size,
	sz: size,
	compar: *sort::cmpfunc,
) void = {
	let slice = (base: *[*]u8)[..nmemb];
	sort::sort(slice, sz, compar);
};

export @symbol("abort") fn _abort() void = {
	abort();
};
