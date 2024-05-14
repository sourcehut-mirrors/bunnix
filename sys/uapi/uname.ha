use errors::{error, errno};
use proc;
use strings;
use types::c;

let hostname: str = "";

export fn sys_uname(uts: *utsname) (u64 | error) = {
	validate_user_addr(uts, size(utsname))?;

	c::fromstr_buf("Bunnix", uts.sysname);
	c::fromstr_buf(hostname, uts.nodename);
	c::fromstr_buf("0.0.0", uts.release);
	c::fromstr_buf("r0", uts.version);
	c::fromstr_buf("x86_64", uts.machine);

	return 0u64;
};

export fn sys_sethostname(name: *str) (u64 | error) = {
	validate_user_addr(name, size(str))?;
	validate_user_string(*name)?;
	if (proc::current().creds.euid != 0) {
		return errno::PERM: error;
	};
	if (len(*name) > 255) {
		return errno::NAMETOOLONG: error;
	};

	hostname = strings::dup(*name);

	return 0u64;
};
