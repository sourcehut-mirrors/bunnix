#include <unistd.h>
#include <errno.h>
#include "syscall.h"

off_t __lseek(int fd, off_t offset, int whence)
{
	return syscall(SYS_lseek, fd, offset, whence);
}

weak_alias(__lseek, lseek);
