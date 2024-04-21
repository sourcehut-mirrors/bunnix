HAREARCH = x86_64
QBEARCH = amd64_sysv
QEMUARCH = x86_64
QEMUFLAGS = -cpu qemu64,fsgsbase
SYSLINUX = /usr/share/syslinux

bunixboot.mb:
	$(HAREBUILD) -T+mb -o $@ boot/mb/
.PHONY: bunixboot.mb

all: bunixboot.mb

bunix.iso: bunixboot.mb boot/mb/syslinux.cfg bunix init
	mkdir -p .isodir
	cp boot/mb/syslinux.cfg .isodir/syslinux.cfg
	install -m644 $(SYSLINUX)/mboot.c32 .isodir/mboot.c32
	install -m644 $(SYSLINUX)/ldlinux.c32 .isodir/ldlinux.c32
	install -m644 $(SYSLINUX)/libcom32.c32 .isodir/libcom32.c32
	install -m644 $(SYSLINUX)/isolinux.bin .isodir/isolinux.bin

	cp bunixboot.mb .isodir/bunixboot.mb
	cp bunix .isodir/bunix
	cp init .isodir/init

	mkisofs -o $@ -b isolinux.bin -c boot.cat \
		-no-emul-boot -boot-load-size 4 -boot-info-table .isodir
	isohybrid $@

run: bunix.iso
	qemu-system-$(QEMUARCH) $(QEMUFLAGS) -m 1G -no-reboot -no-shutdown \
		-drive file=bunix.iso,format=raw \
		-display sdl \
		-serial stdio
.PHONY: run

nographic: bunix.iso
	qemu-system-$(QEMUARCH) $(QEMUFLAGS) -m 1G -no-reboot -no-shutdown \
		-drive file=bunix.iso,format=raw \
		-display none \
		-serial stdio
.PHONY: nographic

gdb: bunix.iso
	qemu-system-$(QEMUARCH) $(QEMUFLAGS) -s -S -m 1G -no-reboot -no-shutdown \
		-drive file=bunix.iso,format=raw \
		-display sdl \
		-serial stdio
.PHONY: gdb

nographic-gdb: bunix.iso
	qemu-system-$(QEMUARCH) $(QEMUFLAGS) -s -S -m 1G -no-reboot -no-shutdown \
		-drive file=bunix.iso,format=raw \
		-display none \
		-serial stdio
.PHONY: nographic-gdb

gdbc:
	gdb -x gdb.cmd
.PHONY: gdbc
