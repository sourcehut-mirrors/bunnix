#ifndef WSTR_H
#define WSTR_H

#include <efi/types.h> // for char16_t

char16_t *wconv(const char *str, char16_t *buf, size_t n);
char *conv(const char16_t *str, char *buf, size_t n);
int wstrcmp(const char16_t *str1, const char16_t *str2);

#endif
