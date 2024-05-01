export type creds = struct {
	// Process ID
	pid: int,
	// Parent process ID
	ppid: int,
	// Process group ID
	pgid: int,
	// Session ID
	sid: int,
	// User ID
	uid: int,
	// Group ID
	gid: int,
	// Effective user ID
	euid: int,
	// Effective group ID
	egid: int,
	// Supplementary group IDs
	groups: []int,
};
