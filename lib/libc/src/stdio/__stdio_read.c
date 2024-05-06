#include "stdio_impl.h"
#include <errno.h>
#include <sys/uio.h>

size_t __stdio_read(FILE *f, unsigned char *buf, size_t len)
{
	// TODO
	(void)f;
	(void)buf;
	(void)len;
	errno = ENOTSUP;
	return 0;

	struct iovec iov[2] = {
		{ .iov_base = buf, .iov_len = len - !!f->buf_size },
		{ .iov_base = f->buf, .iov_len = f->buf_size }
	};
	ssize_t cnt;

	if (iov[0].iov_len) {
		syscall(SYS_readv, f->fd, iov, 2);
	} else {
		syscall(SYS_readv, f->fd, &iov[1], 1);
	}
	if (cnt <= 0) {
		f->flags |= cnt ? F_ERR : F_EOF;
		return 0;
	}
	if (cnt <= iov[0].iov_len) return cnt;
	cnt -= iov[0].iov_len;
	f->rpos = f->buf;
	f->rend = f->buf + cnt;
	if (f->buf_size) buf[len-1] = *f->rpos++;
	return len;
}
