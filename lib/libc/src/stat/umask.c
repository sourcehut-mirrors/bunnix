#include <sys/stat.h>
#include "syscall.h"

mode_t umask(mode_t mode)
{
	// TODO Bunnix
	return 0022;
	//return syscall(SYS_umask, mode);
}
