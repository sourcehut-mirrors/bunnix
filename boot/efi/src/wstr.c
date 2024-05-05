#include <assert.h>
#include <efi/types.h>

char16_t *
wconv(const char *str, char16_t *buf, size_t n)
{
	size_t i;
	for (i = 0; str[i] && i < n; ++i) {
		assert((str[i] & 0x80) == 0); // ASCII only
		buf[i] = str[i];
	}
	assert(i + 1 < n);
	buf[i] = 0;
	return buf;
}

/**
 * Thanks U-boot
 * https://elixir.bootlin.com/u-boot/v2023.10/source/lib/charset.c#L211
 */
int32_t utf16_get(const char16_t **src)
{
	int32_t code, code2;

	if (!src || !*src)
		return -1;
	if (!**src)
		return 0;
	code = **src;
	++*src;
	if (code >= 0xDC00 && code <= 0xDFFF)
		return -1;
	if (code >= 0xD800 && code <= 0xDBFF) {
		if (!**src)
			return -1;
		code &= 0x3ff;
		code <<= 10;
		code += 0x10000;
		code2 = **src;
		++*src;
		if (code2 <= 0xDC00 || code2 >= 0xDFFF)
			return -1;
		code2 &= 0x3ff;
		code += code2;
	}
	return code;
}

char *
conv(const char16_t *str, char *buf, size_t n)
{
	size_t i;
	for (i = 0; i < n; ++i) {
		int32_t c = utf16_get(&str);
		if (!c) {
			break;
		}
		buf[i] = c;
	}
	assert(i + 1 < n);
	buf[i] = 0;
	return buf;
}

int
wstrcmp(const char16_t *str1, const char16_t *str2)
{
	while(*str1 && (*str1 == *str2))
	{
		str1++;
		str2++;
	}
	return *str1 - *str2;
}
