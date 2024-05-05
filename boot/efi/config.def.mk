CROSS_COMPILE=x86_64-w64-mingw32

CC=$(CROSS_COMPILE)-gcc
LD=$(CROSS_COMPILE)-gcc

QEMU=qemu-system-x86_64
OVMF=/usr/share/OVMF
OVMF_FILE=OVMF.fd
HELIOS=../helios
BUNNIX=../bunnix
