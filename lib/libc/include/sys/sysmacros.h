#ifndef _SYS_SYSMACROS_H
#define _SYS_SYSMACROS_H

#define major(x) ((unsigned)((x >> 32) & 0xffffffff))
#define minor(x) ((unsigned)(x & 0xffffffff))

#define makedev(x,y) ((((unsigned long)x) << 32) | (unsigned long)y)

#endif
