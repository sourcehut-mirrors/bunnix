all: bunnix

ROOT=../
include $(ROOT)mk/conf.mk

CFLAGS+=-I$(ROOT)sys/blibc/include -fPIC -mgeneral-regs-only -g

include $(ROOT)vendor/lwext4.mk
include $(ROOT)vendor/libvterm.mk

BUNNIX_TARGETS=\
	$(LIB_LWEXT4_TARGET) \
	$(LIB_LIBVTERM_TARGET)

BUNNIX_LIBS=\
	$(LIB_LWEXT4) \
	$(LIB_LIBVTERM)

BUNNIX_SRCS=$(call rwildcard,.,*.ha *.s *.sc)

vt/alt-8x16.o: vt/alt-8x16
	$(OBJCOPY) -I binary -O elf64-x86-64 $< $@

bunnix: $(BUNNIX_TARGETS) $(BUNNIX_SRCS) vt/alt-8x16.o
	$(KHAREBUILD) $(BUNNIX_LIBS) -o $@

clean:
	rm -f bunnix
	rm -f vt/alt-8x16.o

.PHONY: clean
