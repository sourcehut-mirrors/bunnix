// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use fs;

type os_filesystem = struct {
	fs: fs::fs,
};

@init fn init_cwd() void = {
	// TODO Bunnix
	static let cwd_fs = os_filesystem {
		...
	};
	cwd = &cwd_fs;
};
