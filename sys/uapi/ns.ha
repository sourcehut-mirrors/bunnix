use dev::block;
use errors::{errno, error};
use io;
use fs;
use proc;

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
