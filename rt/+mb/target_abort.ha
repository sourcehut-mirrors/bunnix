fn target_abort(
	path: *str,
	line: u64,
	col: u64,
	msg: str,
) never = {
	writestr("Bootloader abort: ");
	writestr(*path);
	writestr(": ");
	writestr(msg);
	halt();
};
