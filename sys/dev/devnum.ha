// These are fairly arbitrary. Where equivalents are available from Linux we use
// their device major/minor numbers.
export def MAJOR_MEM: uint = 1;
export def MINOR_NULL: uint = 3;		// /dev/null
export def MINOR_ZERO: uint = 5;		// /dev/zero
export def MINOR_NOSPC: uint = 7;		// /dev/nospc
export def MINOR_URANDOM: uint = 9;		// /dev/urandom

// Alternate TTY-like devices
export def MAJOR_TTYALT: uint = 5;
export def MINOR_CONSOLE: uint = 1;		// /dev/console

// TTY devices are assigned as follows:
// /dev/tty*: not used (for now?)
// /dev/ttyS*: serial devices
export def MAJOR_TTY: uint = 4;
export def MINOR_SERIAL_CONS: uint = 64;	// /dev/ttyS*

// /dev/block*
// Minor numbers are assigned in the order they appear in batches of 16
// /dev/block0 is 5:0
// /dev/block0a is 5:1
// /dev/block1 is 5:16
export def MAJOR_BLOCK: uint = 5;

// /dev/input/*
// Minor numbers are assigned in ascending order
export def MAJOR_INPUT: uint = 13;		// /dev/input/*

// /dev/fb*
// Minor numbers are assigned in ascending order
export def MAJOR_FB: uint = 29;			// /dev/fb*
