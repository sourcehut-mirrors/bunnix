# Bunnix

A simple monolithic Unix-like operating system.

## Building Bunnix

You need the following:

* GNU make
* An up-to-date [Hare](https://harelang.org) toolchain. Bunnix tracks Hare
  master, not the latest stable release.
* binutils and gcc configured for x86_64-elf
* e2fsprogs
* mtools
* sfdisk
* xorriso
* qemu-system-x86\_64 and qemu-img

To build with EFI support:

* binutils and gcc configured for x86-64-w64-migw32
* OVMF (only requried if PREFER\_EFI=1, for qemu)

To build with legacy boot support:

* syslinux

Copy conf/x86\_64.mk to config.mk and to taste before moving on.

Use `make` to compile Bunnix. The following targets are available:

* make: builds target/bunnix.iso, which can be written to storage media and
  booted on real hardware
* make nographic: build and run Bunnix in qemu with the serial console connected
  to stdin/out
* make run: build and run Bunnix in qemu with the SDL backend
* make nographic-gdb: nographic but waits for gdb
* make gdb: run but waits for gdb
* make gdbc: connect gdbc to a waiting qemu instance
