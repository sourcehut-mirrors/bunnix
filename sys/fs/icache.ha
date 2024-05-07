use errors::{error, errno};
use io;
use sort;
use sort::cmp;

// Cache of currently-referenced inodes.
export type icache = struct {
	ino: []*io::inode,
};

fn ino_cmp(a: const *opaque, b: const *opaque) int = {
	const a = a: **io::inode;
	const b = b: **io::inode;
	return cmp::uints(&a.ino, &b.ino);
};

// Fetches an inode from the inode cache.
export fn icache_get(ic: *icache, ino: uint) (*io::inode | error) = {
	const model = &io::inode {
		impl = null: *io::inode_iface,
		ino = ino,
		...
	};
	match (sort::search(ic.ino, size(*io::inode), &model, &ino_cmp)) {
	case let i: size =>
		io::inode_ref(ic.ino[i]);
		return ic.ino[i];
	case void =>
		return errno::NOENT;
	};
};

// Adds an inode from the cache. Aborts if the inode was already present in the
// cache.
export fn icache_put(ic: *icache, ino: *io::inode) void = {
	const i = sort::lbisect(ic.ino, size(*io::inode), &ino, &ino_cmp);
	if (i < len(ic.ino)) {
		assert(ic.ino[i].ino != ino.ino);
	};
	insert(ic.ino[i], ino);
};

// Removes an inode from the cache. No effect if the inode was not cached.
export fn icache_remove(ic: *icache, ino: uint) void = {
	const model = &io::inode {
		impl = null: *io::inode_iface,
		ino = ino,
		...
	};
	match (sort::search(ic.ino, size(*io::inode), &model, &ino_cmp)) {
	case let i: size =>
		delete(ic.ino[i]);
	case void =>
		return;
	};
};
