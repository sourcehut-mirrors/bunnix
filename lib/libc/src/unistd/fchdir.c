#define _BSD_SOURCE
#include <unistd.h>
#include <fcntl.h>
#include "syscall.h"

int fchdir(int fd)
{
	struct __chdirat_options opts = {
		.dirfd = fd,
		.flags = AT_EMPTY_PATH,
	};

	int ret = __syscall(SYS_chdirat, &opts);
	return __syscall_ret(ret);
}
