#include <poll.h>
#include <time.h>
#include "syscall.h"

int poll(struct pollfd *fds, nfds_t n, int timeout)
{
	if (timeout <= 0) {
		return syscall(SYS_poll, fds, n, timeout);
	}

	// XXX HACK
	struct timespec ts = {
		.tv_sec = 0,
		.tv_nsec = 2e7, // 20 ms
	};
	for (int i = 0; i < timeout; i += 20) {
		int r = syscall(SYS_poll, fds, n, 0);
		if (r != 0) {
			return r;
		}
		nanosleep(&ts, NULL);
	};
	return syscall(SYS_poll, fds, n, 0);
}
