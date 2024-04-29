export fn sb_get_block_size(s: *sblock) u32 = {
	return 1024 << s.log_block_size;
};
