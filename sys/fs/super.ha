use dev::block;
use io;

// Superblock, i.e. a reference to a single filesystem
export type superblock = struct {
	impl: const *superblock_iface,
};

// Returns the root inode in a [[superblock]].
export type sb_get_root_func = fn(sb: *superblock) *io::inode;

// Superblock interface
export type superblock_iface = struct {
	get_root: *sb_get_root_func,
};

// Returns the root inode of this [[superblock]].
export fn superblock_get_root(sb: *superblock) *io::inode = {
	return sb.impl.get_root(sb);
};
