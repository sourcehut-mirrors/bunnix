all:

ROOT=./
include mk/conf.mk
include mk/$(ARCH).mk

# Kernel
KERNEL_SOURCES=$(call rwildcard,sys,*.ha *.s *.sc)

sys/bunnix: $(KERNEL_SOURCES)
	make -C sys

$(SYSROOT)/boot/bunnix: sys/bunnix
	@$(MKDIR)
	cp $< $@

$(SYSROOT): $(SYSROOT)/boot/bunnix

# Userspace
lib:
	make -C lib install DESTDIR=../$(SYSROOT)
.PHONY: lib

$(SYSROOT)/bin: lib
	mkdir -p $(SYSROOT)/bin
	make -C bin install DESTDIR=../$(SYSROOT)

$(SYSROOT): $(SYSROOT)/bin
	mkdir -p $(SYSROOT)
	for d in \
		bin \
		boot \
		dev \
		etc \
		lib \
		proc \
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
