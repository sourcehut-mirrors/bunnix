#include <sys/stat.h>
#include <unistd.h>
#include "syscall.h"

ssize_t readlink(const char *restrict path, char *restrict buf, size_t bufsize)
{
	struct stat st;
	int r = stat(path, &st);
	if (r != 0) {
		return r;
	};

	// Bunnix does not support symlinks
	errno = EINVAL;
	return -1;
}
