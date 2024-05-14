#include <unistd.h>
#include "syscall.h"

void sync(void)
{
	// no-op on Bunnix (for now)
	return;
}
