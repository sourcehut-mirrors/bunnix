// Obtains a human-friendly reading of an [[errno]] (e.g. "Operation not
// permitted"). The return value may be statically allocated.
export fn strerror(err: error) str = {
	switch (err: errno) {
	case errno::NONE =>
		return "No error";
	case errno::NOMEM =>
		return "Cannot allocate memory";
	case errno::OVERFLOW =>
		return "Value too large for defined data type";
	case errno::UNDERFLOW =>
		return "Value too small for defined data type";
	case errno::INVAL =>
		return "Invalid argument";
	case errno::EXIST =>
		return "File exists";
	case errno::NOTSUP =>
		return "Operation not supported";
	case errno::NOENT =>
		return "No such file or directory";
	case errno::BUSY =>
		return "Device or resource busy";
	case errno::PERM =>
		return "Operation not permitted";
	case errno::IO =>
		return "Input/output error";
	case errno::NXIO =>
		return "No such device or address";
	case errno::E2BIG =>
		return "Argument list too long";
	case errno::ACCES =>
		return "Permission denied";
	case errno::FAULT =>
		return "Bad address";
	case errno::NODEV =>
		return "No such device";
	case errno::NOTDIR =>
		return "Not a directory";
	case errno::ISDIR =>
		return "Is a directory";
	case errno::FBIG =>
		return "File too large";
	case errno::NOSPC =>
		return "No space left on device";
	case errno::ROFS =>
		return "Read-only file system";
	case errno::MLINK =>
		return "Too many links";
	case errno::RANGE =>
		return "Numerical result out of range";
	case errno::NOTEMPTY =>
		return "Directory not empty";
	case errno::NODATA =>
		return "No data available";
	case errno::NOEXEC =>
		return "Exec format error";
	case errno::NOSYS =>
		return "No such syscall";
	case errno::BADF =>
		return "No such file descriptor";
	case errno::CONNREFUSED =>
		return "Connection refused";
	case errno::CANCELED =>
		return "Operation canceled";
	case errno::TIMEDOUT =>
		return "Operation timed out";
	case errno::INTR =>
		return "Interrupted system call";
	case errno::AGAIN =>
		return "Resource temporarily unavailalbe";
	case errno::CHILD =>
		return "No child process";
	case errno::NAMETOOLONG =>
		return "Filename too long";
	};
};
