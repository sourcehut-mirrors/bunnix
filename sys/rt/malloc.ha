// Runtime memory management implementation.
export type malloc_iface = struct {
	malloc: *fn(sz: size) nullable *opaque,
	free_: *fn(ptr: nullable *opaque) void,
	realloc: *fn(p: nullable *opaque, n: size) nullable *opaque,
};

let malloc_impl: nullable *malloc_iface = null;

// Configures the runtime memory allocator.
export fn configure_malloc(impl: *malloc_iface) void = {
	malloc_impl = impl;
};

export fn malloc(n: size) nullable *opaque = {
	const impl = match (malloc_impl) {
	case let impl: *malloc_iface =>
		yield impl;
	case null =>
		abort("alloc called before memory manager was available");
	};
	return impl.malloc(n);
};

export @symbol("rt.free") fn free_(p: nullable *opaque) void = {
	const impl = match (malloc_impl) {
	case let impl: *malloc_iface =>
		yield impl;
	case null =>
		abort("free called before memory manager was available");
	};
	return impl.free_(p);
};

export fn realloc(p: nullable *opaque, n: size) nullable *opaque = {
	const impl = match (malloc_impl) {
	case let impl: *malloc_iface =>
		yield impl;
	case null =>
		abort("realloc called before memory manager was available");
	};
	return impl.realloc(p, n);
};
