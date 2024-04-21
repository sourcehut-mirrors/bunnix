all: bunix init

include config.mk
include mk/$(ARCH).mk

HARECONFIG = -a$(HAREARCH) -T^+$(HAREARCH) -RF
HAREBUILD=HAREPATH=. $(HARE) build $(HARECONFIG)

bunix:
	$(HAREBUILD) -T+bunix -o $@
.PHONY: bunix

init:
	$(HAREBUILD) -T+user -o $@
.PHONY: init
