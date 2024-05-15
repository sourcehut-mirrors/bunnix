# TODO: This file contains some not-x86_64-specific stuff
# Could be generalized if we add another target

all: target/bunnix.iso

ISO_TARGETS=\
	    sys/bunnix \
	    target/initrd

MKISOFSFLAGS=

# Update tools/mkdisk-* if you edit these
DISK_SZ=128M
FAT_PARTSZ=24M
EXT4_PARTSZ=100M

# Legacy boot support
ifeq ($(ENABLE_LEGACY),1)

MULTIBOOT_SOURCES=$(call rwildcard,boot/multiboot,*.ha *.s *.sc)

boot/multiboot/bunnixboot.mb: $(MULTIBOOT_SOURCES) $(KERNEL_SOURCES)
	make -C boot/multiboot/

clean-boot-legacy:
	make -C boot/multiboot/ clean

clean: clean-boot-legacy

$(SYSROOT): $(SYSROOT)/boot/syslinux/syslinux.cfg
$(SYSROOT): $(SYSROOT)/boot/bunnixboot.mb

ISO_TARGETS+=target/iso/boot/bunnixboot.mb
ISO_TARGETS+=target/iso/syslinux.cfg
ISO_TARGETS+=target/iso/mboot.c32
ISO_TARGETS+=target/iso/ldlinux.c32
ISO_TARGETS+=target/iso/libcom32.c32
ISO_TARGETS+=target/iso/isolinux.bin

MKISOFSFLAGS+=\
	-isohybrid-mbr $(SYSLINUX)/isohdpfx.bin \
	-eltorito-boot isolinux.bin \
	-eltorito-catalog boot.cat  \
	-no-emul-boot \
	-boot-load-size 4 \
	-boot-info-table

MBR=$(SYSLINUX)/mbr.bin

else

MBR=/dev/null

endif

# EFI support
ifeq ($(ENABLE_EFI),1)

EFI_SOURCES=$(call rwildcard,boot/multiboot,*.c)

boot/efi/bootx64.efi: $(EFI_SOURCES)
	make -C boot/efi

$(SYSROOT): $(SYSROOT)/boot/EFI/boot/bootx64.efi

ISO_TARGETS+=target/iso/EFI/boot/bootx64.efi
ISO_TARGETS+=target/iso/EFI/isoboot.img

BOOT_EFI=boot/efi/bootx64.efi

ifeq ($(ENABLE_LEGACY),1)

# Prepare dual EFI/legacy boot ISO
MKISOFSFLAGS+=\
	-eltorito-alt-boot \
	-e EFI/isoboot.img \
	-no-emul-boot \
	-isohybrid-gpt-basdat

else

# EFI only
MKISOFSFLAGS+=\
	-efi-boot-part \
	--efi-boot-image \
	-e EFI/isoboot.img \
	-no-emul-boot

endif

else

BOOT_EFI=/dev/null

endif

$(SYSROOT)/boot/bunnixboot.mb: sys/bunnix
	@$(MKDIR)
	cp $< $@

$(SYSROOT)/boot/syslinux/syslinux.cfg: boot/multiboot/syslinux.cfg
	@$(MKDIR)
	cp $< $@

$(SYSROOT)/boot/EFI/boot/bootx64.efi: boot/efi/bootx64.efi
	@$(MKDIR)
	cp $< $@

# Legacy boot support
target/iso/boot/bunnixboot.mb: boot/multiboot/bunnixboot.mb
	@$(MKDIR)
	cp $< $@

target/iso/syslinux.cfg: boot/multiboot/syslinux.cfg
	@$(MKDIR)
	cp $< $@

target/iso/%.c32: $(SYSLINUX)/%.c32
	@$(MKDIR)
	cp $< $@

target/iso/%.bin: $(SYSLINUX)/%.bin
	@$(MKDIR)
	cp $< $@

# EFI support
target/iso/EFI/isoboot.img: target/fs.fat.img
	@$(MKDIR)
	cp $< $@

target/iso/EFI/boot/bootx64.efi: boot/efi/bootx64.efi
	@$(MKDIR)
	cp $< $@

# bunnix.iso
target/iso: $(ISO_TARGETS)
	mkdir -p target/iso/boot/modules
	cp sys/bunnix target/iso/boot/
	cp target/initrd target/iso/boot/modules/
	touch target/iso

target/bunnix.iso: target/iso
	mkisofs -o $@ $(MKISOFSFLAGS) \
		-full-iso9660-filenames \
		-joliet \
		-rational-rock \
		-sysid BUNNIX \
		-volid "Bunnix" \
		-follow-links \
		target/iso

clean-target:
	rm -rf target

.PHONY: clean-target
clean: clean-target

# Disks for emulator use
target/fs.fat.img: $(SYSROOT)
	qemu-img create -f raw $@ $(FAT_PARTSZ)
	mkdosfs $@
	mmd -i $@ ::EFI
	mmd -i $@ ::EFI/boot
	mmd -i $@ ::modules
	mcopy -i $@ $(BOOT_EFI) ::EFI/boot/bootx64.efi
	mcopy -i $@ $(SYSROOT)/boot/bunnix ::bunnix
	mcopy -i $@ target/initrd ::modules/initrd

target/fs.ext4.img: $(SYSROOT)
	qemu-img create -f raw $@ $(EXT4_PARTSZ)
	mkfs.ext4 -d $(SYSROOT) -O^metadata_csum $@

.PHONY: target/fs.ext4.img
.PHONY: target/fs.fat.img

target/disk.mbr.img: target/fs.fat.img target/fs.ext4.img
	qemu-img create -f raw $@ $(DISK_SZ)
	sfdisk $@ < tools/mkdisk-mbr
	dd if=$(MBR) conv=notrunc of=$@
	dd if=target/fs.fat.img conv=notrunc of=$@ seek=2048
	dd if=target/fs.ext4.img conv=notrunc of=$@ seek=51200

target/disk.gpt.img: target/fs.fat.img target/fs.ext4.img
	qemu-img create -f raw $@ $(DISK_SZ)
	sfdisk $@ < tools/mkdisk-gpt
	dd if=target/fs.fat.img conv=notrunc of=$@ seek=2048
	dd if=target/fs.ext4.img conv=notrunc of=$@ seek=51200

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
	-cdrom target/bunnix.iso

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
