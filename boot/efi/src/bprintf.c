#include <assert.h>
#include <efi/system-table.h>
#include <limits.h>
#include <stdarg.h>
#include "hboot.h"
#include "wstr.h"

#define BUFSIZ 256

struct bufio {
	char buf[BUFSIZ];
	size_t nbuf;
};

static void
puts(const char *s)
{
	char16_t wbuf[BUFSIZ];
	char16_t *ws = wconv(s, wbuf, BUFSIZ);
	g_systab->ConOut->OutputString(g_systab->ConOut, ws);
}

static void
bflush(struct bufio *buf)
{
	buf->buf[buf->nbuf] = 0;
	puts(buf->buf);
	buf->nbuf = 0;
}

static int
bwrite(struct bufio *buf, char c)
{
	const size_t maxbuf = BUFSIZ - 1;
	if (buf->nbuf >= maxbuf) {
		bflush(buf);
	}
	buf->buf[buf->nbuf++] = c;
	return 1;
}

static const char xdigits[16] = {
	"0123456789abcdef"
};

static char *
fmt_x(uintmax_t x, char *s)
{
	*--s = 0;
	if (x == 0) {
		*s = '0';
		return s;
	}
	for (; x; x>>=4) *--s = xdigits[(x&15)];
	return s;
}

static char *
fmt_u(uintmax_t x, char *s)
{
	unsigned long y;
	*--s = 0;
	if (x == 0) {
		*s = '0';
		return s;
	}
	for (   ; x>ULONG_MAX; x/=10) *--s = '0' + x%10;
	for (y=x;           y; y/=10) *--s = '0' + y%10;
	return s;
}

int
bprintfln(const char *fmt, ...)
{
	int n = 0;
	char ebuf0[3 * sizeof(int)], *ebuf = &ebuf0[3 * sizeof(int)];
	struct bufio buf = {0};

	va_list ap;
	va_start(ap, fmt);
	for (size_t i = 0; fmt[i]; ++i) {
		if (fmt[i] != '%') {
			n += bwrite(&buf, fmt[i]);
			continue;
		}
		bflush(&buf);

		intmax_t ival;
		uintmax_t uval;
		switch (fmt[++i]) {
		case 's':
			puts(va_arg(ap, const char *));
			break;
		case 'd':
			ival = va_arg(ap, int);
			if (ival < 0) {
				puts("-");
				ival = -ival;
			}
			uval = (uintmax_t)ival;
			puts(fmt_u(uval, ebuf));
			break;
		case 'u':
			uval = (uintmax_t)va_arg(ap, unsigned int);
			puts(fmt_u(uval, ebuf));
			break;
		case 'p':
			uval = (uintmax_t)va_arg(ap, uintptr_t);
			puts("0x");
			puts(fmt_x(uval, ebuf));
			break;
		case 'x':
			uval = (uintmax_t)va_arg(ap, unsigned int);
			puts(fmt_x(uval, ebuf));
			break;
		default:
			assert(0);
		}
	}
	bflush(&buf);
	puts("\r\n");
	va_end(ap);
	return n;
}
