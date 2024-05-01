use fs;
use io;

def ROOT_INODE: uint = 1;

export type superblock = struct {
	fs::superblock,
	next_ino: uint,
	root: inode,
};

// Creates a new in-memory filesystem.
export fn new() *fs::superblock = {
	let sb = alloc(superblock {
		impl = &super_impl,
		next_ino = 1,
		root = mkinode(
			null: *superblock,
			ROOT_INODE,
			io::mode::DIR | 0o755,
		),
	});
	sb.root.sb = sb;
	return sb;
};

const super_impl = fs::superblock_iface {
	get_root = &sb_get_root,
};

fn sb_get_root(sb: *fs::superblock) *io::inode = {
	const sb = sb: *superblock;
	return &sb.root;
};

fn sb_get_ino(sb: *superblock) uint = {
	defer sb.next_ino += 1;
	return sb.next_ino;
};
