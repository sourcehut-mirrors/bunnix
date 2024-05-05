#include <efi/system-table.h>
#include <efi/types.h>
#include "bprintf.h"
#include "hboot.h"

_Noreturn void
__assert_fail(const char *expr, const char *file, int line, const char *func)
{
	bprintfln("Assertion failed: %s (%s: %s: %d)",
			expr, file, func, line);
	__builtin_trap();
}
