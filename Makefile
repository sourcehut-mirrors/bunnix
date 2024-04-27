all: bunnix init

include config.mk
include mk/$(ARCH).mk

HARECONFIG = -a$(HAREARCH) -T^+$(HAREARCH) -RF
HAREBUILD=ASFLAGS=-g HAREPATH=. $(HARE) build $(HARECONFIG)

include vendor/Makefile

bunnix: $(CTARGETS)
	$(HAREBUILD) $(LIBS) -T+bunnix -o $@
.PHONY: bunnix

init:
	$(HAREBUILD) -T+user -o $@ cmd/init/
.PHONY: init

clean: clean-arch clean-vendor
	rm -f bunnix init
