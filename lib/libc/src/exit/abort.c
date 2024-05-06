#include <stdlib.h>
#include "syscall.h"

_Noreturn void abort(void)
{
	//raise(SIGABRT); // TODO
	_Exit(127);
}
