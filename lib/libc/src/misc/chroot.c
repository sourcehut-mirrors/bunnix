#define _GNU_SOURCE
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include "syscall.h"

int chroot(const char *path)
{
	__string_t spath = sys_string(path, strlen(path));
	return syscall(SYS_chrootat, AT_FDCWD, &spath, 0);
}
