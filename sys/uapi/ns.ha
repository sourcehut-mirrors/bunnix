use dev::block;
use errors::{errno, error};
use fs;
use io;
use proc;
use strings;

fn sys_mount(opts: *mount_options) (u64 | error) = {
	validate_user_addr(opts, size(mount_options))?;
	validate_user_string(opts.device)?;
	validate_user_string(opts.fstype)?;
	validate_user_string(opts.mountpoint)?;
	validate_user_slice(opts.misc, size(str))?;
	for (let i = 0z; i < len(opts.misc); i += 1) {
		validate_user_string(opts.misc[i])?;
	};

	const cur = proc::current();
	if (cur.creds.euid != 0) {
		// TODO: Unprivileged mounts
		return errno::PERM: error;
	};

	let bdev: nullable *block::blockdev = null;

	if (opts.device != "") {
		const (devnode, _) = fs::walk(cur.root, opts.device)?;
		if (!io::isblockdev(devnode.mode)) {
			// TODO: Return NOTBLK
			return errno::NXIO: error;
		};
		const major = (devnode.rdev >> 32): u32;
		const minor = devnode.rdev: u32;
		bdev = block::opendev(major, minor)?;
		io::inode_unref(devnode);
	};

	let fsopts = fs::fs_opts {
		device = bdev,
		fstype = opts.fstype,
		readonly = opts.readonly,
		misc = opts.misc,
	};

	const fs = fs::fs_open(&fsopts)?;
	fs::mount_fs(cur.root, fs, opts.mountpoint)?;

	return 0u64;
};

fn sys_chrootat(dirfd: i64, path: *str, flags: int) (u64 | error) = {
	validate_user_addr(path, size(str))?;
	validate_user_string(*path)?;

	const (targ, _) = atwalk(dirfd: int, *path)?;
	if (!io::isdir(targ.mode)) {
		io::inode_unref(targ);
		return errno::NOTDIR: error;
	};

	// Note: Bunnix sets the cwd to / when doing chroot, which differs from
	// most Unicies but is less dumb
	let cur = proc::current();
	io::inode_unref(cur.root);
	io::inode_unref(cur.cwd);
	io::inode_ref(targ); // ref both root and cwd

	cur.root = targ;
	cur.cwd = targ;
	free(cur.cwd_str);
	cur.cwd_str = strings::dup("/");

	return 0u64;
};
