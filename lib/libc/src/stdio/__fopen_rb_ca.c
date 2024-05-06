#include "stdio_impl.h"
#include <fcntl.h>
#include <string.h>
#include <errno.h>

FILE *__fopen_rb_ca(const char *filename, FILE *f, unsigned char *buf, size_t len)
{
	memset(f, 0, sizeof *f);

	struct __openat_options opts = {
		.dirfd = AT_FDCWD,
		.path = sys_string(filename, strlen(filename)),
		.flags = O_RDONLY|O_CLOEXEC,
		.mode = 0,
	};
	f->fd = syscall(SYS_openat, &opts);
	if (f->fd < 0) return 0;

	f->flags = F_NOWR | F_PERM;
	f->buf = buf + UNGET;
	f->buf_size = len - UNGET;
	f->read = __stdio_read;
	f->seek = __stdio_seek;
	f->close = __stdio_close;
	f->lock = -1;

	return f;
}
