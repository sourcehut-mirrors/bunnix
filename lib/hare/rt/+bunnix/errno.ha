// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

// Represents an error returned from the Bunnix kernel.
export type errno = !int;

fn syswrap(ret: (u64, u64)) (u64 | errno) = {
	const (status, result) = ret;
	if (status == 0) {
		return result;
	};
	return status: errno;
};

// Obtains a human-friendly reading of an [[errno]] (e.g. "Operation not
// permitted"). The return value may be statically allocated.
export fn strerror(err: errno) str = {
	switch (err) {
	case ENOMEM =>
		return "Cannot allocate memory";
	case EOVERFLOW =>
		return "Value too large for defined data type";
	case EUNDERFLOW =>
		return "Value too small for defined data type";
	case EINVAL =>
		return "Invalid argument";
	case EEXIST =>
		return "File exists";
	case ENOTSUP =>
		return "Operation not supported";
	case ENOENT =>
		return "No such file or directory";
	case EBUSY =>
		return "Device or resource busy";
	case EPERM =>
		return "Operation not permitted";
	case EIO =>
		return "Input/output error";
	case ENXIO =>
		return "No such device or address";
	case E2BIG =>
		return "Argument list too long";
	case EACCES =>
		return "Permission denied";
	case EFAULT =>
		return "Bad address";
	case ENODEV =>
		return "No such device";
	case ENOTDIR =>
		return "Not a directory";
	case EISDIR =>
		return "Is a directory";
	case EFBIG =>
		return "File too large";
	case ENOSPC =>
		return "No space left on device";
	case EROFS =>
		return "Read-only file system";
	case EMLINK =>
		return "Too many links";
	case ERANGE =>
		return "Numerical result out of range";
	case ENOTEMPTY =>
		return "Directory not empty";
	case ENODATA =>
		return "No data available";
	case ENOEXEC =>
		return "Exec format error";
	case ENOSYS =>
		return "No such syscall";
	case EBADF =>
		return "No such file descriptor";
	case ECONNREFUSED =>
		return "Connection refused";
	case ECANCELED =>
		return "Operation canceled";
	case ETIMEDOUT =>
		return "Operation timed out";
	case EINTR =>
		return "Interrupted system call";
	case EAGAIN =>
		return "Resource temporarily unavailable";
	case =>
		return unknown_errno(err);
	};
};

// Gets the programmer-friendly name for an [[errno]] (e.g. EPERM). The return
// value may be statically allocated.
export fn errname(err: errno) str = {
	switch (err) {
	case ENOMEM =>
		return "ENOMEM";
	case EOVERFLOW =>
		return "EOVERFLOW";
	case EUNDERFLOW =>
		return "EUNDERFLOW";
	case EINVAL =>
		return "EINVAL";
	case EEXIST =>
		return "EEXIST";
	case ENOTSUP =>
		return "ENOTSUP";
	case ENOENT =>
		return "ENOENT";
	case EBUSY =>
		return "EBUSY";
	case EPERM =>
		return "EPERM";
	case EIO =>
		return "EIO";
	case ENXIO =>
		return "ENXIO";
	case E2BIG =>
		return "E2BIG";
	case EACCES =>
		return "EACCES";
	case EFAULT =>
		return "EFAULT";
	case ENODEV =>
		return "ENODEV";
	case ENOTDIR =>
		return "ENOTDIR";
	case EISDIR =>
		return "EISDIR";
	case EFBIG =>
		return "EFBIG";
	case ENOSPC =>
		return "ENOSPC";
	case EROFS =>
		return "EROFS";
	case EMLINK =>
		return "EMLINK";
	case ERANGE =>
		return "ERANGE";
	case ENOTEMPTY =>
		return "ENOTEMPTY";
	case ENODATA =>
		return "ENODATA";
	case ENOEXEC =>
		return "ENOEXEC";
	case ENOSYS =>
		return "ENOSYS";
	case EBADF =>
		return "EBADF";
	case ECONNREFUSED =>
		return "ECONNREFUSED";
	case ECANCELED =>
		return "ECANCELED";
	case ETIMEDOUT =>
		return "ETIMEDOUT";
	case EINTR =>
		return "EINTR";
	case EAGAIN =>
		return "EAGAIN";
	case =>
		return unknown_errno(err);
	};
};

export def ENOMEM: errno = 1;
export def EOVERFLOW: errno = 2;
export def EUNDERFLOW: errno = 3;
export def EINVAL: errno = 4;
export def EEXIST: errno = 5;
export def ENOTSUP: errno = 6;
export def ENOENT: errno = 7;
export def EBUSY: errno = 8;
export def EPERM: errno = 9;
export def EIO: errno = 10;
export def ENXIO: errno = 11;
export def E2BIG: errno = 12;
export def EACCES: errno = 13;
export def EFAULT: errno = 14;
export def ENODEV: errno = 15;
export def ENOTDIR: errno = 16;
export def EISDIR: errno = 17;
export def EFBIG: errno = 18;
export def ENOSPC: errno = 19;
export def EROFS: errno = 20;
export def EMLINK: errno = 21;
export def ERANGE: errno = 22;
export def ENOTEMPTY: errno = 23;
export def ENODATA: errno = 24;
export def ENOEXEC: errno = 25;
export def ENOSYS: errno = 26;
export def EBADF: errno = 27;
export def ECONNREFUSED: errno = 28;
export def ECANCELED: errno = 29;
export def ETIMEDOUT: errno = 30;
export def EINTR: errno = 31;
export def EAGAIN: errno = 32;
