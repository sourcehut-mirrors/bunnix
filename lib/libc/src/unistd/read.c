#include <unistd.h>
#include <sys/uio.h>
#include "syscall.h"

ssize_t read(int fd, void *buf, size_t count)
{
	struct iovec iov = {
		.iov_base = (void *)buf,
		.iov_len = count
	};
	return syscall(SYS_readv, fd, &iov, 1);
}
