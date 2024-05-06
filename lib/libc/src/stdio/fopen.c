#include "stdio_impl.h"
#include <fcntl.h>
#include <string.h>
#include <errno.h>

FILE *fopen(const char *restrict filename, const char *restrict mode)
{
	FILE *f;
	int fd;
	int flags;

	/* Check for valid initial mode character */
	if (!strchr("rwa", *mode)) {
		errno = EINVAL;
		return 0;
	}

	/* Compute the flags to pass to open() */
	flags = __fmodeflags(mode);

	struct __openat_options opts = {
		.dirfd = AT_FDCWD,
		.path = sys_string(filename, strlen(filename)),
		.flags = flags,
		.mode = 0,
	};
	fd = syscall(SYS_openat, &opts);
	if (fd < 0) return 0;

	fd = syscall(SYS_openat, &opts);

	f = __fdopen(fd, mode);
	if (f) return f;

	syscall(SYS_close, fd);
	return 0;
}
