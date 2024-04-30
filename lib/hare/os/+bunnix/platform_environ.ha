// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors;
use math;
use rt;
use strings;
use types::c;

// The command line arguments provided to the program. By convention, the first
// member is usually the name of the program.
export let args: []str = [];

// Statically allocate arg strings if there are few enough arguments, saves a
// syscall if we don't need it.
let args_static: [32]str = [""...];

@init fn args() void = {
	return; // TODO Bunnix

};

@fini fn args() void = {
	return; // TODO Bunnix
};

// Returns a slice of the environment strings in the form KEY=VALUE.
export fn getenvs() []str = {
	return envp; // TODO Bunnix
};

// Returns the number of usable CPUs.
export fn cpucount() (size | errors::error) = {
	return 1; // TODO Bunnix
};

