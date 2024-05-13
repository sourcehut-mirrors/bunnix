#include <sys/resource.h>
#include <errno.h>
#include <stdio.h>
#include "syscall.h"

int getrlimit(int resource, struct rlimit *rlim)
{
	// TODO Bunnix
	*rlim = (struct rlimit){
		.rlim_cur = 4096,
		.rlim_max = 4096,
	};
	return 0;
}
