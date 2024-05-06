#include <errno.h>
#include "stdio_impl.h"

int __stdio_close(FILE *f)
{
	return -ENOTSUP; // TODO
	//return syscall(SYS_close, f->fd);
}
