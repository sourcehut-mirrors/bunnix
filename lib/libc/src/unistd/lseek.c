#include <unistd.h>
#include <errno.h>
#include "syscall.h"

off_t __lseek(int fd, off_t offset, int whence)
{
	errno = ENOSYS;
	return (off_t)-1;
}

weak_alias(__lseek, lseek);
