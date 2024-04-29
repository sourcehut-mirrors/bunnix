all: bunnixboot.mb

ROOT=../../
include $(ROOT)/mk/conf.mk

MULTIBOOT_SRCS=$(wildcard *.ha)
MULTIBOOT_SRCS+=$(call rwildcard,$(ROOT)/sys/boot,*.ha *.s *.sc)
MULTIBOOT_SRCS+=$(call rwildcard,$(ROOT)/sys/rt,*.ha *.s *.sc)

bunnixboot.mb: $(MULTIBOOT_SRCS)
	$(BHAREBUILD) -o $@

clean:
	rm -f bunnixboot.mb

.PHONY: clean
