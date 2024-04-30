use arch;
use mman;

// Switches to the next available task.
export fn schedule() void = {
	const next = match (task_next()) {
	case let t: *task =>
		yield t;
	case null =>
		abort(); // TODO: idle
	};

	mman::vmm_map(next.vmm);
	arch::switch_user(&next.ctx);
};
