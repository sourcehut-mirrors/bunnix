use arch;

// Switches to the next available task.
export fn schedule() never = {
	const next = match (task_next()) {
	case let t: *task =>
		yield t;
	case null =>
		abort(); // TODO: idle
	};

	// TODO: Don't enter user just yet?
	arch::enter_user(&next.ctx);
};
