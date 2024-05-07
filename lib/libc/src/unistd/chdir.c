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

	int ret = __syscall(SYS_chdirat, &opts);
	return __syscall_ret(ret);
}
