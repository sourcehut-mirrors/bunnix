CFLAGS=-ffreestanding -Iinclude/ -Wall -Wextra -Wpedantic -Werror
LDFLAGS=-nostdlib -Wl,-dll -shared -Wl,--subsystem,10 -e efi_main

include config.mk

all: bootx64.efi

src/%.o: src/%.c include/* include/efi/*
	$(CC) $(CFLAGS) -c -o $@ $<

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

bootx64.efi: $(BOOT_OBJ)
	$(LD) $(LDFLAGS) -o $@ $(BOOT_OBJ)

boot.img: bootx64.efi $(BUNNIX)/sys/bunnix $(BUNNIX)/target/initrd
	dd if=/dev/zero of=$@ bs=512 count=93750 status=none
	parted $@ -s -a minimal mklabel gpt
	parted $@ -s -a minimal mkpart EFI FAT16 2048s 93716s
	parted $@ -s -a minimal toggle 1 boot
	dd if=/dev/zero of=part.img bs=512 count=91668 status=none # 93750 - 2048
	mformat -i part.img -h 32 -t 32 -n 64 -c 1
	mmd -i part.img ::EFI
	mmd -i part.img ::EFI/boot
	mmd -i part.img ::modules
	mcopy -i part.img bootx64.efi ::EFI/boot/bootx64.efi
	mcopy -i part.img $(BUNNIX)/sys/bunnix ::bunnix
	mcopy -i part.img $(BUNNIX)/target/initrd ::modules/initrd
	dd if=part.img of=$@ bs=512 count=91668 seek=2048 conv=notrunc status=none


clean:
	rm -f src/*.o bootx64.efi boot.img part.img

nographic: boot.img
	$(QEMU) -L $(OVMF) -bios $(OVMF_FILE) \
		-m 1G -no-reboot -no-shutdown \
		-drive file=boot.img,format=raw \
		-display none \
		-serial stdio -enable-kvm

run: boot.img
	$(QEMU) -L $(OVMF) -bios $(OVMF_FILE) \
		-m 1G -no-reboot -no-shutdown \
		-drive file=boot.img,format=raw \
		-display sdl \
		-serial stdio

check: test.img
	$(QEMU) -L $(OVMF) -bios $(OVMF_FILE) \
		-m 1G -no-reboot -no-shutdown \
		-drive file=test.img,format=raw \
		-display none \
		-serial stdio

nographic-gdb: boot.img
	$(QEMU) -L $(OVMF) -bios $(OVMF_FILE) -s -S \
		-m 1G -no-reboot -no-shutdown \
		-drive file=boot.img,format=raw \
		-display none \
		-serial stdio

.PHONY: all clean nographic
