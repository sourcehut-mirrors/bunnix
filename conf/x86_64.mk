# Set this to the desired target architecture. Valid options include:
#
# - x86_64
ARCH = x86_64

# Sane defaults, feel free to configure:
TRIPLET = x86_64-elf-
HARE = hare
HAREC = harec
QBE = qbe
AS = $(TRIPLET)as
LD = $(TRIPLET)ld
OBJCOPY = $(TRIPLET)objcopy
GDB = $(TRIPLET)gdb
DTC = $(TRIPLET)dtc
CC = $(TRIPLET)gcc

SYSLINUX = /usr/share/syslinux

EFI_CC=x86-64-w64-migw32-gcc
EFI_LD=x86-64-w64-mingw43-gcc

OVMF=/usr/share/OVMF
OVMF_FILE=OVMF.fd
