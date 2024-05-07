#include <fcntl.h>
#include <stdarg.h>
#include <string.h>
#include "syscall.h"

int open(const char *filename, int flags, ...)
{
	mode_t mode = 0;

	if ((flags & O_CREAT) || (flags & O_TMPFILE) == O_TMPFILE) {
		va_list ap;
		va_start(ap, flags);
		mode = va_arg(ap, mode_t);
		va_end(ap);
	}

	struct __openat_options opts = {
		.dirfd = AT_FDCWD,
		.path = sys_string(filename, strlen(filename)),
		.flags = flags,
		.mode = mode,
	};

	int r = syscall(SYS_openat, &opts);
	return __syscall_ret(r);
}
