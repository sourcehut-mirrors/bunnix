use io;
use time;

// Updates a time value of an inode.
export fn put_time(
	spec: *io::timespec,
	tm: nullable *io::timespec = null,
) void = {
	if (tm == null) {
		let now = io::timespec { ... };
		const instant = time::now(time::clock::REALTIME);
		now.tv_sec = instant.sec;
		now.tv_nsec = instant.nsec;
		tm = &now;
	};
	*spec = *(tm as *io::timespec);
};
