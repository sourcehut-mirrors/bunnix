#include <fcntl.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <time.h>
#include "syscall.h"

int utimensat(int fd, const char *path, const struct timespec times[2], int flags)
{
	struct timespec _times[2] = {0};
	if (times) {
		_times[0] = times[0];
		_times[1] = times[1];
	}
	if (times && times[0].tv_nsec == UTIME_NOW) {
		clock_gettime(CLOCK_REALTIME, &_times[0]);
	}
	if (times && times[1].tv_nsec == UTIME_NOW) {
		clock_gettime(CLOCK_REALTIME, &_times[1]);
	}

	struct __utimensat_options opts = {
		.dirfd = fd,
		.path = path ? sys_string(path, strlen(path)) : (__string_t){0},
		.flags = flags,
		.atime = times && _times[0].tv_nsec != UTIME_OMIT ? &_times[0] : NULL,
		.mtime = times && _times[0].tv_nsec != UTIME_OMIT ? &_times[1] : NULL,
	};
	return syscall(SYS_utimensat, &opts);
}
