#include <errno.h>

int __errno;

int *__errno_location(void)
{
	return &__errno;
}

weak_alias(__errno_location, ___errno_location);
