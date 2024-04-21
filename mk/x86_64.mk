HAREARCH = x86_64
QBEARCH = amd64_sysv
QEMUARCH = x86_64
QEMUFLAGS = -cpu qemu64,fsgsbase
SYSLINUX = /usr/share/syslinux

bunnixboot.mb:
	$(HAREBUILD) -T+mb -o $@ boot/mb/
.PHONY: bunnixboot.mb

all: bunnixboot.mb

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

arch-clean:
	rm -rf bunnix.iso bunnixboot.mb .isodir
.PHONY: arch-clean

run: bunnix.iso
	qemu-system-$(QEMUARCH) $(QEMUFLAGS) -m 1G -no-reboot -no-shutdown \
		-drive file=bunnix.iso,format=raw \
		-display sdl \
		-serial stdio
.PHONY: run

nographic: bunnix.iso
	qemu-system-$(QEMUARCH) $(QEMUFLAGS) -m 1G -no-reboot -no-shutdown \
		-drive file=bunnix.iso,format=raw \
		-display none \
		-serial stdio
.PHONY: nographic

gdb: bunnix.iso
	qemu-system-$(QEMUARCH) $(QEMUFLAGS) -s -S -m 1G -no-reboot -no-shutdown \
		-drive file=bunnix.iso,format=raw \
		-display sdl \
		-serial stdio
.PHONY: gdb

nographic-gdb: bunnix.iso
	qemu-system-$(QEMUARCH) $(QEMUFLAGS) -s -S -m 1G -no-reboot -no-shutdown \
		-drive file=bunnix.iso,format=raw \
		-display none \
		-serial stdio
.PHONY: nographic-gdb

gdbc:
	gdb -x gdb.cmd
.PHONY: gdbc
