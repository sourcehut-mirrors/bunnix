use fs;

def ROOT_INODE: uint = 1;

export type superblock = struct {
	fs::superblock,
	root: inode,
};

// Creates a new in-memory filesystem.
export fn new() *fs::superblock = {
	let sb = alloc(superblock {
		impl = &super_impl,
		root = mkinode(
			null: *superblock,
			ROOT_INODE,
			fs::mode::DIR | 0o755,
		),
	});
	sb.root.sb = sb;
	return sb;
};

const super_impl = fs::superblock_iface {
	get_root = &sb_get_root,
};

fn sb_get_root(sb: *fs::superblock) *fs::inode = {
	const sb = sb: *superblock;
	return &sb.root;
};
