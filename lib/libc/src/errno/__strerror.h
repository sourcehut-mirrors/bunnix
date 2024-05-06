/* The first entry is a catch-all for codes not enumerated here.
 * This file is included multiple times to declare and define a structure
 * with these messages, and then to define a lookup table translating
 * error codes to offsets of corresponding fields in the structure. */

E(0,            "No error information")
E(ENOMEM,       "Out of memory")
E(EOVERFLOW,    "Value too large for data type")
E(EUNDERFLOW,   "Value too small for data type")
E(EINVAL,       "Invalid argument")
E(EEXIST,       "File exists")
E(ENOTSUP,      "Not supported")
E(ENOENT,       "No such file or directory")
E(EBUSY,        "Resource busy")
E(EPERM,        "Operation not permitted")
E(EIO,          "I/O error")
E(ENXIO,        "No such device or address")
E(E2BIG,        "Argument list too long")
E(EACCES,       "Permission denied")
E(EFAULT,       "Bad address")
E(ENODEV,       "No such device")
E(ENOTDIR,      "Not a directory")
E(EISDIR,       "Is a directory")
E(EFBIG,        "File too large")
E(ENOSPC,       "No space left on device")
E(EROFS,        "Read-only file system")
E(EMLINK,       "Too many links")
E(ERANGE,       "Result not representable")
E(ENOTEMPTY,    "Directory not empty")
E(ENODATA,      "No data available")
E(ENOEXEC,      "Exec format error")
E(ENOSYS,       "Function not implemented")
E(EBADF,        "Bad file descriptor")
E(ECONNREFUSED, "Connection refused")
E(ECANCELED,    "Operation canceled")
E(ETIMEDOUT,    "Operation timed out")
E(EINTR,        "Interrupted system call")
E(EAGAIN,       "Resource temporarily unavailable")
E(ECHILD,       "No child process")

// libc-internal errors

E(EILSEQ,       "Illegal byte sequence")
