#ifndef	_SYS_MMAN_H
#define	_SYS_MMAN_H
#ifdef __cplusplus
extern "C" {
#endif

#include <features.h>

#define __NEED_mode_t
#define __NEED_size_t
#define __NEED_off_t

#if defined(_GNU_SOURCE)
#define __NEED_ssize_t
#endif

#include <bits/alltypes.h>

#define MAP_FAILED ((void *) -1)

#define MAP_SHARED     (1 << 2)
#define MAP_PRIVATE    (1 << 1)
#define MAP_FIXED      (1 << 3)
#define MAP_ANON       (1 << 0)
#define MAP_ANONYMOUS  MAP_ANON
#define MAP_LOCKED     0	/* Not implemented by Bunnix */
#define MAP_POPULATE   0	/* Not implemented by Bunnix */
#define MAP_NONBLOCK   0	/* Not implemented by Bunnix */
#define MAP_FIXED_NOREPLACE 0x100000

#define PROT_NONE      0
#define PROT_READ      1
#define PROT_WRITE     2
#define PROT_EXEC      4

#include <bits/mman.h>

void *mmap (void *, size_t, int, int, int, off_t);
int munmap (void *, size_t);

int mprotect (void *, size_t, int);
int msync (void *, size_t, int);

int posix_madvise (void *, size_t, int);

int mlock (const void *, size_t);
int munlock (const void *, size_t);
int mlockall (int);
int munlockall (void);

struct __mmap_options {
	void *addr;
	size_t len;
	int prot;
	int flags;
	int fd;
	off_t off;
};

#ifdef _GNU_SOURCE
void *mremap (void *, size_t, size_t, int, ...);
int remap_file_pages (void *, size_t, int, size_t, int);
int memfd_create (const char *, unsigned);
int mlock2 (const void *, size_t, unsigned);
#endif

#if defined(_GNU_SOURCE) || defined(_BSD_SOURCE)
int madvise (void *, size_t, int);
int mincore (void *, size_t, unsigned char *);
#endif

int shm_open (const char *, int, mode_t);
int shm_unlink (const char *);

#if defined(_LARGEFILE64_SOURCE)
#define mmap64 mmap
#define off64_t off_t
#endif

#ifdef __cplusplus
}
#endif
#endif
