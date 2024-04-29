# Recursive targets
boot/multiboot/bunnixboot.mb:
	make -C boot/multiboot/

.PHONY: boot/multiboot/bunnixboot.mb

clean-boot:
	make -C boot/multiboot/ clean

.PHONY: clean-boot
clean: clean-boot

all: target/bunnix.iso

target/fs.fat.img:
	mkdir -p target
	qemu-img create -f raw $@ 48M
	mkdosfs $@
	# Add some files for interest
	mcopy -i $@ README.md ::README.md
	mcopy -i $@ COPYING ::COPYING

target/fs.ext4.img:
	mkdir -p target/root/

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

	make -C bin install DESTDIR=../target/root
	git archive HEAD | tar -C target/root/src -x

	qemu-img create -f raw $@ 48M
	mkfs.ext4 -d target/root/ -O^metadata_csum $@

.PHONY: target/fs.ext4.img
.PHONY: target/fs.fat.img

target/disk.mbr.img: target/fs.fat.img target/fs.ext4.img
	qemu-img create -f raw $@ 128M
	sfdisk $@ < tools/mkdisk-mbr
	dd if=target/fs.fat.img of=$@ seek=2048
	dd if=target/fs.ext4.img of=$@ seek=133120

target/disk.gpt.img:
	qemu-img create -f raw $@ 128M
	sfdisk $@ < tools/mkdisk-gpt

ISO_TARGETS=\
	boot/multiboot/bunnixboot.mb \
	boot/multiboot/syslinux.cfg \
	sys/bunnix

target/bunnix.iso: $(ISO_TARGETS)
	mkdir -p target/iso
	cp boot/multiboot/syslinux.cfg target/iso/syslinux.cfg
	install -m644 $(SYSLINUX)/mboot.c32 target/iso/mboot.c32
	install -m644 $(SYSLINUX)/ldlinux.c32 target/iso/ldlinux.c32
	install -m644 $(SYSLINUX)/libcom32.c32 target/iso/libcom32.c32
	install -m644 $(SYSLINUX)/isolinux.bin target/iso/isolinux.bin

	cp boot/multiboot/bunnixboot.mb target/iso/bunnixboot.mb
	cp sys/bunnix target/iso/bunnix

	mkisofs -o $@ -b isolinux.bin -c boot.cat -l \
		-no-emul-boot -boot-load-size 4 -boot-info-table target/iso
	isohybrid $@

clean-target:
	rm -rf target

.PHONY: clean-target
clean: clean-target

QEMUARGS=\
	$(QEMUFLAGS) -m 1G -no-reboot -no-shutdown \
	-drive file=target/bunnix.iso,format=raw \
	-drive id=disk-mbr,file=target/disk.mbr.img,if=none,format=raw \
	-drive id=disk-gpt,file=target/disk.gpt.img,if=none,format=raw \
	-device ahci,id=ahci \
	-device ide-hd,drive=disk-mbr,bus=ahci.0 \
	-device ide-hd,drive=disk-gpt,bus=ahci.1
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
