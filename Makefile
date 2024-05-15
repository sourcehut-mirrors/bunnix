all:

ROOT=./
include mk/conf.mk
include mk/$(ARCH).mk

bootstrap:
	mkdir -p $(SYSROOT)
	make -C lib/libc install-headers DESTDIR=../../$(SYSROOT)
	@echo
	@echo ------====================================================================------
	@echo
	@echo Your bootstrap sysroot is now ready:
	@echo
	@echo sysroot=$$(readlink -f $$PWD/$(SYSROOT))
	@echo
	@echo ------====================================================================------
	@echo

.PHONY: bootstrap

# Kernel
KERNEL_SOURCES=$(call rwildcard,sys,*.ha *.s *.sc)

sys/bunnix: $(KERNEL_SOURCES)
	make -C sys

$(SYSROOT)/boot/bunnix: sys/bunnix
	@$(MKDIR)
	cp $< $@

$(SYSROOT): $(SYSROOT)/boot/bunnix

# Userspace
LIBC_SOURCES=$(call rwildcard,lib/libc,*.c *.h *.S)

$(SYSROOT)/usr/lib/libc.a: $(LIBC_SOURCES)
	make -C lib install DESTDIR=../$(SYSROOT)

$(SYSROOT)/bin: $(SYSROOT)/usr/lib/libc.a
	mkdir -p $(SYSROOT)/bin
	make -C bin install DESTDIR=../$(SYSROOT)

$(SYSROOT)/sbin: $(SYSROOT)/usr/lib/libc.a
	mkdir -p $(SYSROOT)/sbin
	make -C sbin install DESTDIR=../$(SYSROOT)

.PHONY: $(SYSROOT)/sbin

ETC_FILES=$(wildcard etc/*)

$(SYSROOT)/etc: $(ETC_FILES)
	mkdir -p $(SYSROOT)/etc
	cp $(ETC_FILES) $(SYSROOT)/etc
	chmod 600 $(SYSROOT)/etc/shadow

$(SYSROOT): $(SYSROOT)/bin $(SYSROOT)/sbin $(SYSROOT)/etc
	mkdir -p $(SYSROOT)
	for d in \
		boot \
		dev \
		lib \
		proc \
		root \
		tmp \
		var; \
	do mkdir -p $(SYSROOT)/$$d; \
	done

target/initrd: $(SYSROOT)
	# TODO: gzip me
	cd $(SYSROOT) && tar -cvf ../../$@ *

.PHONY: target/initrd

ifeq ($(INSTALL_SRC), 1)

$(SYSROOT)/src:
	@mkdir -p $(SYSROOT)/src
	git archive HEAD | tar -C $(SYSROOT)/src -x

.PHONY: $(SYSROOT)/src

$(SYSROOT): $(SYSROOT)/src

endif

clean-bin:
	make -C bin clean

clean-sys:
	make -C sys clean

clean-sysroot:
	rm -rf $(SYSROOT)

clean-vendor:
	make -C vendor clean

.PHONY: clean-bin
.PHONY: clean-sys
.PHONY: clean-sysroot
.PHONY: clean-vendor

clean: clean-bin clean-sys clean-sysroot clean-vendor
