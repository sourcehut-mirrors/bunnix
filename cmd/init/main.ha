use rt;

export fn main() void = {
	for (let i = 0u64; i < 5; i += 1) {
		rt::test(i, i + 1, i + 2);
	};
};
