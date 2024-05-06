#include "stdio_impl.h"

#ifdef __GNUC__
__attribute__((__noinline__))
#endif
static int locking_putc(int c, FILE *f)
{
	c = putc_unlocked(c, f);
	return c;
}

static inline int do_putc(int c, FILE *f)
{
	return putc_unlocked(c, f);
}
