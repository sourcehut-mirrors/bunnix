#include <stddef.h>
#include <bits.h>

typedef struct file FILE;

#define stdin ((FILE *)0)
#define stdout ((FILE *)1)
#define stderr ((FILE *)2)

int printf(const char *restrict format, ...);
int fprintf(FILE *f, const char *restrict format, ...);
int fflush(FILE *stream);
int puts(const char *s);
int snprintf(char *str, size_t size, const char *restrict format, ...);
int vsnprintf(char *str, size_t size, const char *restrict format, va_list ap);
