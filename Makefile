all: bunnix init

include config.mk
include mk/$(ARCH).mk

HARECONFIG = -a$(HAREARCH) -T^+$(HAREARCH) -RF
HAREBUILD=HAREPATH=. $(HARE) build $(HARECONFIG)

bunnix:
	$(HAREBUILD) -T+bunnix -o $@
.PHONY: bunnix

init:
	$(HAREBUILD) -T+user -o $@ cmd/init/
.PHONY: init

clean: arch-clean
	rm -f bunnix init
