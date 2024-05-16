#include <unistd.h>
#include <sys/mman.h>
#include <errno.h>
#include <stdint.h>
#include <limits.h>
#include "syscall.h"

void *__mmap(void *start, size_t len, int prot, int flags, int fd, off_t off)
{
	long ret;
	if (len >= PTRDIFF_MAX) {
		errno = ENOMEM;
		return MAP_FAILED;
	}

	struct __mmap_options opts = {
		.addr = start,
		.len = len,
		.prot = prot,
		.flags = flags,
		.fd = fd,
		.off = off,
	};

	ret = __syscall(SYS_mmap, &opts);

	void *out = (void *)__syscall_ret(ret);
	if (ret < 0) {
		return MAP_FAILED;
	}
	return out;
}

weak_alias(__mmap, mmap);
