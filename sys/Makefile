all: bunnix

ROOT=../
include $(ROOT)mk/conf.mk

CFLAGS+=-I$(ROOT)sys/blibc/include -fPIC -mgeneral-regs-only -g

include $(ROOT)vendor/lwext4.mk

BUNNIX_TARGETS=\
	$(LIB_LWEXT4_TARGET)

BUNNIX_LIBS=\
	$(LIB_LWEXT4)

BUNNIX_SRCS=$(call rwildcard,sys,*.ha *.s *.sc)

bunnix: $(BUNNIX_TARGETS) $(BUNNIX_SRCS)
	$(KHAREBUILD) $(BUNNIX_LIBS) -o $@

clean:
	rm -f bunnix

.PHONY: clean
