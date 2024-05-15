#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include "syscall.h"

int remove(const char *path)
{
	int r = unlinkat(AT_FDCWD, path, 0);
	if (r < 0 && errno == EISDIR) {
		r = unlinkat(AT_FDCWD, path, AT_REMOVEDIR);
	};
	return r;
}
