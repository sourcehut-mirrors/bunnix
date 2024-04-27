# Bunnix

A simple monolithic Unix-like operating system.

## Building Bunnix

You need the following:

* An up-to-date [Hare](https://harelang.org) toolchain. Bunnix tracks Hare
  master, not the latest stable release.
* binutils and gcc configured for an x86_64-elf target
* e2fsprogs
* mtools
* sfdisk
* syslinux
* xorriso
* qemu-system-x86_64 and qemu-img

Consider editing config.mk to taste before moving on.

Use `make` to compile Bunnix. The following targets are available:

* make: builds bunnix.iso, which can be written to storage media and booted on
  real hardware
* make nographic: build and run Bunnix in qemu with the serial console connected
  to stdin/out
* make run: build and run Bunnix in qemu with the SDL backend
* make nographic-gdb: nographic but waits for gdb
* make gdb: run but waits for gdb
* make gdbc: connect gdbc to a waiting qemu instance
