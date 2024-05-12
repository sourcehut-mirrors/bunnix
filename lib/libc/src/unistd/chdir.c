#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include "syscall.h"

int chdir(const char *path)
{
	struct __chdirat_options opts = {
		.dirfd = AT_FDCWD,
		.path = sys_string(path, strlen(path)),
		.flags = 0,
	};

	return syscall(SYS_chdirat, &opts);
}
