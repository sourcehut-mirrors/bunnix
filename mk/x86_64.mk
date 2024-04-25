HAREARCH = x86_64
QBEARCH = amd64_sysv
QEMUARCH = x86_64
QEMUFLAGS = -cpu qemu64,fsgsbase
SYSLINUX = /usr/share/syslinux

bunnixboot.mb:
	$(HAREBUILD) -T+mb -o $@ boot/mb/
.PHONY: bunnixboot.mb

all: bunnixboot.mb bunnix.iso

fs.fat.img:
	qemu-img create -f raw $@ 48M
	mkdosfs $@
	mcopy -i $@ README.md ::README.md
	mcopy -i $@ COPYING ::COPYING

fs.ext4.img:
	mkdir -p .ext4dir
	# Copy the source tree into the ext4 system just to have some
	# interesting files to look at
	git archive --prefix=bunnix/ HEAD | tar -C .ext4dir/ -x
	mkdir -p \
		.ext4dir/bin \
		.ext4dir/boot \
		.ext4dir/dev \
		.ext4dir/etc \
		.ext4dir/lib \
		.ext4dir/proc \
		.ext4dir/tmp \
		.ext4dir/var
	qemu-img create -f raw $@ 48M
	mkfs.ext4 -d .ext4dir -O^metadata_csum $@

disk.mbr.img: fs.fat.img fs.ext4.img
	qemu-img create -f raw $@ 128M
	sfdisk $@ < scripts/mkdisk-mbr
	dd if=fs.fat.img of=$@ seek=2048
	dd if=fs.ext4.img of=$@ seek=133120

disk.gpt.img: fs.fat.img
	qemu-img create -f raw $@ 128M
	sfdisk $@ < scripts/mkdisk-gpt

bunnix.iso: bunnixboot.mb boot/mb/syslinux.cfg bunnix init
	mkdir -p .isodir
	cp boot/mb/syslinux.cfg .isodir/syslinux.cfg
	install -m644 $(SYSLINUX)/mboot.c32 .isodir/mboot.c32
	install -m644 $(SYSLINUX)/ldlinux.c32 .isodir/ldlinux.c32
	install -m644 $(SYSLINUX)/libcom32.c32 .isodir/libcom32.c32
	install -m644 $(SYSLINUX)/isolinux.bin .isodir/isolinux.bin

	cp bunnixboot.mb .isodir/bunnixboot.mb
	cp bunnix .isodir/bunnix
	cp init .isodir/init

	mkisofs -o $@ -b isolinux.bin -c boot.cat \
		-no-emul-boot -boot-load-size 4 -boot-info-table .isodir
	isohybrid $@

clean-arch:
	rm -rf bunnix.iso bunnixboot.mb .isodir
.PHONY: arch-clean

QEMUARGS=\
	$(QEMUFLAGS) -m 1G -no-reboot -no-shutdown \
	-drive file=bunnix.iso,format=raw \
	-drive id=disk-mbr,file=disk.mbr.img,if=none,format=raw \
	-drive id=disk-gpt,file=disk.gpt.img,if=none,format=raw \
	-device ahci,id=ahci \
	-device ide-hd,drive=disk-mbr,bus=ahci.0 \
	-device ide-hd,drive=disk-gpt,bus=ahci.1

run: bunnix.iso disk.mbr.img disk.gpt.img
	qemu-system-$(QEMUARCH) $(QEMUARGS) \
		-display sdl \
		-serial stdio
.PHONY: run

nographic: bunnix.iso disk.mbr.img disk.gpt.img
	qemu-system-$(QEMUARCH) $(QEMUARGS) \
		-display none \
		-serial stdio
.PHONY: nographic

gdb: bunnix.iso disk.mbr.img disk.gpt.img
	qemu-system-$(QEMUARCH) $(QEMUARGS) -s -S \
		-display sdl \
		-serial stdio
.PHONY: gdb

nographic-gdb: bunnix.iso disk.mbr.img disk.gpt.img
	qemu-system-$(QEMUARCH) $(QEMUARGS) -s -S \
		-display none \
		-serial stdio
.PHONY: nographic-gdb

gdbc:
	gdb -x gdb.cmd
.PHONY: gdbc
