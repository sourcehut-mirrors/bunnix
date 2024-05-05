# Recursive targets
boot/multiboot/bunnixboot.mb:
	make -C boot/multiboot/

.PHONY: boot/multiboot/bunnixboot.mb

clean-boot:
	make -C boot/multiboot/ clean

.PHONY: clean-boot
clean: clean-boot

all: target/bunnix.iso

ROOT=target/root
ROOT_TARGETS=\
	$(ROOT)/boot/bunnix \
	$(ROOT)/boot/bunnixboot.mb \
	$(ROOT)/boot/syslinux/syslinux.cfg

$(ROOT): $(ROOT_TARGETS)
	mkdir -p $(ROOT)
	for d in \
		bin \
		boot/syslinux \
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

target/fs.fat.img:
	mkdir -p target
	qemu-img create -f raw $@ 48M
	mkdosfs $@
	# Add some files for interest
	mcopy -i $@ README.md ::README.md
	mcopy -i $@ COPYING ::COPYING

target/fs.ext4.img: $(ROOT)
	qemu-img create -f raw $@ 48M
	mkfs.ext4 -d $(ROOT) -O^metadata_csum $@

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

target/initrd: $(ROOT)
	# TODO: gzip me
	cd $(ROOT) && tar -cvf ../../$@ *

ISO_TARGETS=\
	    boot/multiboot/bunnixboot.mb \
	    boot/multiboot/syslinux.cfg \
	    sys/bunnix \
	    target/initrd

target/iso: $(ISO_TARGETS)
	mkdir -p target/iso/boot

	install -m644 $(SYSLINUX)/mboot.c32 target/iso/mboot.c32
	install -m644 $(SYSLINUX)/ldlinux.c32 target/iso/ldlinux.c32
	install -m644 $(SYSLINUX)/libcom32.c32 target/iso/libcom32.c32
	install -m644 $(SYSLINUX)/isolinux.bin target/iso/isolinux.bin

	cp sys/bunnix target/iso/boot/
	cp target/initrd target/iso/boot/
	cp boot/multiboot/bunnixboot.mb target/iso/boot/
	cp boot/multiboot/syslinux.cfg target/iso/

target/bunnix.iso: target/iso
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
