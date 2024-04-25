use dev::block;

// Superblock, i.e. a reference to a single filesystem
export type superblock = struct {
	impl: const *superblock_iface,
};

// Returns the root inode in a [[superblock]].
export type sb_get_root_func = fn(sb: *superblock) *inode;

// Superblock interface
export type superblock_iface = struct {
	get_root: *sb_get_root_func,
};

export fn superblock_get_root(sb: *superblock) *inode = {
	return sb.impl.get_root(sb);
};
