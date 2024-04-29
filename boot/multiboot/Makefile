all: bunnixboot.mb

ROOT=../../
include $(ROOT)/mk/conf.mk

MULTIBOOT_SRCS=$(call rwildcard,boot/multiboot,*.ha *.s *.sc)

bunnixboot.mb: $(MULTIBOOT_SRCS)
	$(BHAREBUILD) -o $@

clean:
	rm -f bunnixboot.mb

.PHONY: clean
