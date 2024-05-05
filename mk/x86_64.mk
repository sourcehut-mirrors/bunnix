# TODO: This file contains some not-x86_64-specific stuff
# Could be generalized if we add another target

all: target/bunnix.iso

ROOT=target/root
ROOT_TARGETS=\
	$(ROOT)/boot/bunnix

ISO_TARGETS=\
	    sys/bunnix \
	    target/initrd

MKISOFSFLAGS=

# Legacy boot support
ifeq ($(ENABLE_LEGACY),1)

boot/multiboot/bunnixboot.mb:
	make -C boot/multiboot/
.PHONY: boot/multiboot/bunnixboot.mb

clean-boot-legacy:
	make -C boot/multiboot/ clean

clean: clean-boot-legacy

ROOT_TARGETS+=$(ROOT)/boot/syslinux/syslinux.cfg
ROOT_TARGETS+=$(ROOT)/boot/bunnixboot.mb

ISO_TARGETS+=target/iso/boot/bunnixboot.mb
ISO_TARGETS+=target/iso/syslinux.cfg
ISO_TARGETS+=target/iso/mboot.c32
ISO_TARGETS+=target/iso/ldlinux.c32
ISO_TARGETS+=target/iso/libcom32.c32
ISO_TARGETS+=target/iso/isolinux.bin

MKISOFSFLAGS+=-b isolinux.bin

MBR=$(SYSLINUX)/mbr.bin

else

MBR=/dev/null

endif

# EFI support
ifeq ($(ENABLE_EFI),1)

boot/efi/bootx64.efi:
	make -C boot/efi
.PHONY: boot/efi/bootx64.efi

ROOT_TARGETS+=$(ROOT)/boot/EFI/boot/bootx64.efi

ISO_TARGETS+=target/iso/EFI/boot/bootx64.efi

BOOT_EFI=boot/efi/bootx64.efi

else

BOOT_EFI=/dev/null

endif

$(ROOT): $(ROOT_TARGETS)
	mkdir -p $(ROOT)
	for d in \
		bin \
		boot \
		dev \
		etc \
		lib \
		proc \
		src \
		tmp \
		var; \
	do mkdir -p target/root/$$d; \
	done

	make -C bin install DESTDIR=../$(ROOT)
	git archive HEAD | tar -C $(ROOT)/src -x

$(ROOT)/boot/bunnix: sys/bunnix
	mkdir -p $(ROOT)/boot
	cp $< $@

$(ROOT)/boot/bunnixboot.mb: sys/bunnix
	mkdir -p $(ROOT)/boot
	cp $< $@

$(ROOT)/boot/syslinux/syslinux.cfg: boot/multiboot/syslinux.cfg
	mkdir -p $(ROOT)/boot/syslinux
	cp $< $@

$(ROOT)/boot/EFI/boot/bootx64.efi: boot/efi/bootx64.efi
	mkdir -p $(ROOT)/boot/EFI/boot
	cp $< $@

target/initrd: $(ROOT)
	# TODO: gzip me
	cd $(ROOT) && tar -cvf ../../$@ *

# Legacy boot support
target/iso/boot/bunnixboot.mb: boot/multiboot/bunnixboot.mb
	mkdir -p $$(dirname $@)
	cp $< $@

target/iso/syslinux.cfg: boot/multiboot/syslinux.cfg
	mkdir -p $$(dirname $@)
	cp $< $@

target/iso/%.c32: $(SYSLINUX)/%.c32
	mkdir -p $$(dirname $@)
	cp $< $@

target/iso/%.bin: $(SYSLINUX)/%.bin
	mkdir -p $$(dirname $@)
	cp $< $@

# EFI support
target/iso/EFI/boot/bootx64.efi: boot/efi/bootx64.efi
	mkdir -p $$(dirname $@)
	cp $< $@

# bunnix.iso
target/iso: $(ISO_TARGETS)
	mkdir -p target/iso/boot/modules
	cp sys/bunnix target/iso/boot/
	cp target/initrd target/iso/boot/modules/
	touch target/iso

target/bunnix.iso: target/iso
	mkisofs -o $@ $(MKISOFSFLAGS) -c boot.cat -l \
		-no-emul-boot -boot-load-size 4 -boot-info-table target/iso
	isohybrid $@

clean-target:
	rm -rf target

.PHONY: clean-target
clean: clean-target

# Disks for emulator use
target/fs.fat.img: $(ROOT)
	mkdir -p target
	qemu-img create -f raw $@ 48M
	mkdosfs $@
	mmd -i $@ ::EFI
	mmd -i $@ ::EFI/boot
	mmd -i $@ ::modules
	mcopy -i $@ $(BOOT_EFI) ::EFI/boot/bootx64.efi
	mcopy -i $@ $(ROOT)/boot/bunnix ::bunnix
	mcopy -i $@ target/initrd ::modules/initrd

target/fs.ext4.img: $(ROOT)
	qemu-img create -f raw $@ 48M
	mkfs.ext4 -d $(ROOT) -O^metadata_csum $@

.PHONY: target/fs.ext4.img
.PHONY: target/fs.fat.img

target/disk.mbr.img: target/fs.fat.img target/fs.ext4.img
	qemu-img create -f raw $@ 128M
	sfdisk $@ < tools/mkdisk-mbr
	dd if=$(MBR) conv=notrunc of=$@
	dd if=target/fs.fat.img conv=notrunc of=$@ seek=2048
	dd if=target/fs.ext4.img conv=notrunc of=$@ seek=133120

target/disk.gpt.img: target/fs.fat.img target/fs.ext4.img
	qemu-img create -f raw $@ 128M
	sfdisk $@ < tools/mkdisk-gpt
	dd if=target/fs.fat.img conv=notrunc of=$@ seek=2048
	dd if=target/fs.ext4.img conv=notrunc of=$@ seek=133120

# Emulator targets
#
QEMUARGS=$(QEMUFLAGS) -m 1G -no-reboot -no-shutdown

ifeq ($(PREFER_EFI),0)

QEMUARGS+=\
	-drive file=target/bunnix.iso,format=raw \
	-drive id=disk-mbr,file=target/disk.mbr.img,if=none,format=raw \
	-drive id=disk-gpt,file=target/disk.gpt.img,if=none,format=raw \
	-device ahci,id=ahci \
	-device ide-hd,drive=disk-mbr,bus=ahci.0 \
	-device ide-hd,drive=disk-gpt,bus=ahci.1

else

QEMUARGS+=\
	-L $(OVMF) -bios $(OVMF_FILE) \
	-drive file=target/bunnix.iso,format=raw \
	-drive id=disk-mbr,file=target/disk.mbr.img,if=none,format=raw \
	-drive id=disk-gpt,file=target/disk.gpt.img,if=none,format=raw \
	-device ahci,id=ahci \
	-device ide-hd,drive=disk-gpt,bus=ahci.0 \
	-device ide-hd,drive=disk-mbr,bus=ahci.1

endif

QEMU_TARGETS=\
	target/bunnix.iso \
	target/disk.mbr.img \
	target/disk.gpt.img

run: $(QEMU_TARGETS)
	qemu-system-$(QEMUARCH) $(QEMUARGS) \
		-display sdl \
		-serial stdio

nographic: $(QEMU_TARGETS)
	qemu-system-$(QEMUARCH) $(QEMUARGS) \
		-display none \
		-serial stdio

gdb: $(QEMU_TARGETS)
	qemu-system-$(QEMUARCH) $(QEMUARGS) -s -S \
		-display sdl \
		-serial stdio

nographic-gdb: $(QEMU_TARGETS)
	qemu-system-$(QEMUARCH) $(QEMUARGS) -s -S \
		-display none \
		-serial stdio

gdbc:
	gdb -x gdb.cmd

.PHONY: run nographic gdb nographic-gdb gdbc
