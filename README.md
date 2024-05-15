# Bunnix

A simple monolithic Unix-like operating system.

## Bunnix cross toolchain

A GNU toolchain configured for an x86_64-bunnix target is required to compile
Bunnix. Fetch the binutils and gcc trees from here:

* [binutils](https://git.sr.ht/~sircmpwn/binutils) (bunnix branch)
* [gcc](https://git.sr.ht/~sircmpwn/gcc) (bunnix branch)

You must configure these with the Bunnix sysroot you will be using for your
build. The build system places this at $srcdir/target/root/ by default.

First run "make bootstrap" to initialize the sysroot. This will print the path
to the configured sysroot. Assuming $sysroot refers to this path, an example
binutils configuration could be:

```
./configure \
    --target=x86_64-bunnix \
    --prefix=/usr/local \
    --with-sysroot=$sysroot \
    --disable-werror \
    --disable-nls
make
make install
```

And GCC:

```
./configure \
    --target=x86_64-bunnix \
    --prefix=/usr/local \
    --with-sysroot=$sysroot \
    --enable-languages=c,c++ \
    --disable-gcov \
    --disable-nlp
make all-gcc all-target-libgcc
make install-gcc install-target-libgcc
make all-target-libstdc++-v3
make install-target-libstdc++-v3
```

## Building Bunnix

You need the following:

* binutils and gcc configured for x86_64-bunnix (see above)
* An up-to-date [Hare](https://harelang.org) toolchain. Bunnix tracks Hare
  master, not the latest stable release.
* GNU make
* e2fsprogs
* mtools
* sfdisk
* xorriso
* qemu-system-x86\_64 and qemu-img
* yacc

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

## Included third-party software

Bunnix includes (often patched versions of) the following third-party software:

* [lwext4](https://github.com/gkostka/lwext4): ext4 implementation (kernel)
* [dash](https://git.sr.ht/~sircmpwn/dash): /bin/sh
* [sbase](https://git.sr.ht/~sircmpwn/sbase): core utilities*
* [lok](https://github.com/dimkr/lok): /bin/awk
* [musl libc](http://musl.libc.org/): the libc is derived from musl
* [gzip](https://www.gnu.org/software/gzip/): for installing ports
* [tcc](https://bellard.org/tcc/): C compiler

\* sbase is good software written by questionable people. I do not endorse
   suckless.
