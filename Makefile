all:

ROOT=./
include mk/conf.mk
include mk/$(ARCH).mk

sys/bunnix:
	make -C sys

.PHONY: sys/bunnix

clean-bin:
	make -C bin clean

clean-sys:
	make -C sys clean

clean-vendor:
	make -C vendor clean

.PHONY: clean-bin
.PHONY: clean-sys
.PHONY: clean-vendor

clean: clean-bin clean-sys clean-vendor
