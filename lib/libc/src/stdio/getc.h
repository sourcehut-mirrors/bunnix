#include "stdio_impl.h"

#ifdef __GNUC__
__attribute__((__noinline__))
#endif
static int locking_getc(FILE *f)
{
	int c = getc_unlocked(f);
	return c;
}

static inline int do_getc(FILE *f)
{
	return getc_unlocked(f);
}
