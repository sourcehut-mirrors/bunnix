#define _BSD_SOURCE
#include <sys/stat.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <stdint.h>
#include <string.h>
#include <sys/sysmacros.h>
#include "syscall.h"

int __fstatat(int fd, const char *restrict path, struct stat *restrict st, int flag)
{
	struct __fstatat_options opts = {
		.dirfd = fd,
		.path = sys_string(path, strlen(path)),
		.st = st,
		.flags = flag,
	};
	int ret = syscall(SYS_fstatat, &opts);
	return __syscall_ret(ret);
}

weak_alias(__fstatat, fstatat);
