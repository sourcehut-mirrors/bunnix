typedef struct file FILE;

#define stdin ((FILE *)0)
#define stdout ((FILE *)1)
#define stderr ((FILE *)2)

int printf(const char *restrict format, ...);
int fflush(FILE *stream);
int puts(const char *s);
