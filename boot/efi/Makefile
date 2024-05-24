all: bootx64.efi

ROOT=../../
include $(ROOT)/mk/conf.mk

include $(ROOT)/vendor/zlib.mk

CFLAGS=-ffreestanding -Iinclude/ -I$(ROOT)/vendor/zlib \
       -Wall -Wextra -Wpedantic -Werror
LDFLAGS=-nostdlib -Wl,-dll -shared -Wl,--subsystem,10 -e efi_main

all: bootx64.efi

src/%.o: src/%.c include/* include/efi/* $(LIBZ_TARGET)
	$(EFI_CC) $(CFLAGS) -c -o $@ $<

BOOT_OBJ=\
	 src/assert.o \
	 src/bprintf.o \
	 src/fs.o \
	 src/gop.o \
	 src/guids.o \
	 src/load.o \
	 src/main.o \
	 src/modules.o \
	 src/mmap.o \
	 src/mmu.o \
	 src/string.o \
	 src/wstr.o

bootx64.efi: $(BOOT_OBJ) $(LIBZ_TARGET)
	$(EFI_LD) $(LDFLAGS) -o $@ $(BOOT_OBJ) $(LIBZ)

clean:
	rm -f src/*.o bootx64.efi

.PHONY: all clean
