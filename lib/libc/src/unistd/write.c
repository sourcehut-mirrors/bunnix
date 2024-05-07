#include <unistd.h>
#include <sys/uio.h>
#include "syscall.h"

ssize_t write(int fd, const void *buf, size_t count)
{
	struct iovec iov = {
		.iov_base = (void *)buf,
		.iov_len = count
	};
	return syscall(SYS_writev, fd, &iov, 1);
}
