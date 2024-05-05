use arch;
use boot;
use format::tar;
use format::tar::{entry_type};
use fs::memfs;
use fs;
use io;
use log;
use memio;
use path;

fn mount_initrd(vfs: *fs::vfs, mod: *boot::module) void = {
	log::kprintf(KERN, "Mount root from initrd: ");
	const base = arch::phys_tokernel(mod.phys): *[*]u8;
	const data = base[..mod.length];
	const in = memio::fixed(data);

	const fs = memfs::new();
	fs::mount_root(&root, fs);
	const root = fs::superblock_get_root(fs);

	let nino = 0z;
	const rd = tar::read(&in);
	for (let ent => tar::next(&rd)!) {
		defer nino += 1;
		defer tar::skip(&ent)!;

		// TODO: Extract other sorts of files?
		const mode = ent.mode: io::mode;
		const ftype = ent.etype;
		if (ftype != entry_type::DIRECTORY && ftype != entry_type::FILE) {
			continue;
		};

		const orig = io::tell(&in)!;
		const filedata = memio::borrowedread(&in, ent.fsize) as []u8;
		defer io::seek(&in, orig, io::whence::SET)!;

		const path = path::init(ent.name)!;
		const iter = path::iter(&path);
		const (parent, final) = fs::inode_walk(
			root, &iter, fs::walkflag::PARENT)!;

		if (ftype == entry_type::DIRECTORY) {
			let inode = io::inode_mkdir(parent, final, mode)!;
			inode.uid = ent.uid;
			inode.gid = ent.gid;
			io::inode_unref(inode);
			continue;
		};

		let inode = io::inode_create(parent, final, mode)!: *memfs::inode;
		inode.data = filedata;
		inode.uid = ent.uid;
		inode.gid = ent.gid;
		inode.bytes = ent.fsize;
		io::inode_unref(inode);
	};

	log::printfln("{} inodes", nino);
};
