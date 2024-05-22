# Set this to the desired target architecture. Valid options include:
#
# - x86_64
ARCH = x86_64

# Sane defaults, feel free to configure:
HOSTCC = gcc
TRIPLET = x86_64-bunnix
HARE = hare
HAREC = harec
QBE = qbe
AS = $(TRIPLET)-as
LD = $(TRIPLET)-ld
OBJCOPY = $(TRIPLET)-objcopy
STRIP = $(TRIPLET)-strip
GDB = $(TRIPLET)-gdb
DTC = $(TRIPLET)-dtc
CC = $(TRIPLET)-gcc
CXX = $(TRIPLET)-g++
AR = $(TRIPLET)-ar
RANLIB = $(TRIPLET)-ranlib

#
# Bootloader configuration
ENABLE_EFI=1
ENABLE_LEGACY=1

# 1: make nographic et al will boot with EFI
# 0: make nographic et al will boot with legacy boot
PREFER_EFI=0

# Legacy boot configuration
# Only required if ENABLE_LEGACY=1
SYSLINUX = /usr/share/syslinux

# EFI boot configuration
# Only required if ENABLE_EFI=1
EFI_TRIPLET=x86_64-w64-mingw32-
EFI_CC=$(EFI_TRIPLET)gcc
EFI_LD=$(EFI_TRIPLET)gcc

OVMF=/usr/share/OVMF
OVMF_FILE=OVMF.fd

#
# Userspace configuration

# Install Bunnix source code to /src?
INSTALL_SRC=1
