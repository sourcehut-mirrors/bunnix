#include "locale_impl.h"
#include "libc.h"

locale_t __uselocale(locale_t new)
{
	// stub
	return &libc.global_locale;
}

weak_alias(__uselocale, uselocale);
