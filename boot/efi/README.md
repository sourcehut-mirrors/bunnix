# hboot

hboot is a simple EFI bootloader to support the [Helios] boot protocol on
x86\_64.

[Helios]: https://sr.ht/~sircmpwn/helios

## Building hboot

Install the dependencies:

- gcc for x86\_64-w64-mingw32
- binutils for x86\_64-w64-mingw32

Copy config.def.mk to config.mk and edit as necessary, then run "make".

## Installing hboot

"make" will build the bootloader executable, bootx64.efi. Install this to an EFI
system partition at EFI/boot/bootx64.efi, or according to your local EFI
configuration requirements. The bootloader will load the kernel from the same
filesystem via /helios, and loads boot modules (such as init) via /modules/* in
alphabetical order.

## Testing hboot locally

Install additional debug dependencies:

- qemu-system-x86\_64
- parted
- mtools
- ovmf

Ensure that config.mk includes an appropriate path for OVMF and HELIOS,
respectively to the install directory for the OVMF distribution and to a
pre-built Helios source tree. Run "make nographic" to build a test environment
and boot it with qemu.
