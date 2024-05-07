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
	case errno::ADDRINUSE =>
		return "Address in use";
	case errno::ADDRNOTAVAIL =>
		return "Address not available";
	case errno::AFNOSUPPORT =>
		return "Address family not supported by protocol";
	case errno::ALREADY =>
		return "Operation already in progress";
	case errno::CONNRESET =>
		return "Connection reset by peer";
	case errno::DEADLK =>
		return "Resource deadlock would occur";
	case errno::DESTADDRREQ =>
		return "Destination address required";
	case errno::DOM =>
		return "Domain error";
	case errno::HOSTUNREACH =>
		return "Host is unreachable";
	case errno::INPROGRESS =>
		return "Operation in progress";
	case errno::ISCONN =>
		return "Socket is connected";
	case errno::LOOP =>
		return "Symbolic link loop";
	case errno::MFILE =>
		return "No file descriptors available";
	case errno::MSGSIZE =>
		return "Message too large";
	case errno::NETDOWN =>
		return "Network is down";
	case errno::NETRESET =>
		return "Connection reset by network";
	case errno::NETUNREACH =>
		return "Network unreachable";
	case errno::NFILE =>
		return "Too many open files in system";
	case errno::NOBUFS =>
		return "No buffer space available";
	case errno::NOPROTOOPT =>
		return "Protocol not available";
	case errno::NOTCONN =>
		return "Socket not connected";
	case errno::NOTSOCK =>
		return "Not a socket";
	case errno::NOTTY =>
		return "Not a tty";
	case errno::PIPE =>
		return "Broken pipe";
	case errno::PROTONOSUPPORT =>
		return "Protocol not supported";
	case errno::PROTOTYPE =>
		return "Protocol wrong type for socket";
	case errno::SPIPE =>
		return "Invalid seek";
	case errno::SRCH =>
		return "No such process";
	case errno::WOULDBLOCK =>
		return "Resource temporarily unavailable";
	case errno::XDEV =>
		return "Cross-device link";
	case errno::CONNABORTED =>
		return "Connection aborted";
	case errno::NOLCK =>
		return "No locks available";
	case errno::OPNOTSUPP =>
		return "Not supported";
	};
};
