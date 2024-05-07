all: libc.a crt0.o

PREFIX=/usr
LIBDIR=$(PREFIX)/lib
INCLUDEDIR=$(PREFIX)/include

ROOT=../../
include $(ROOT)mk/conf.mk

CFLAGS = -std=c11 -g -nostdinc -ffreestanding \
	 -fno-stack-protector -fno-unwind-tables -fno-asynchronous-unwind-tables \
	 -ffunction-sections -fdata-sections \
	 -Wall -Wextra -Werror \
	 -Wno-unused-parameter -Wno-sign-compare -Wno-parentheses \
	 -Wno-implicit-fallthrough -Wno-dangling-pointer \
	 -Wno-unused-function -Wno-unused-but-set-variable \
	 -Wno-unknown-pragmas -Wno-missing-braces
CFLAGS += -D_XOPEN_SOURCE=700 -Isrc/include/ -Isrc/internal/ -Iout/include/ -Iarch/$(ARCH)/ -Iarch/generic/ -Iinclude/
LDFLAGS = -Wl,--sort-section,alignment -Wl,--sort-common -Wl,--gc-sections -Wl,--hash-style=both -Wl,--no-undefined -Wl,--exclude-libs=ALL

EMPTY_LIB_NAMES = m rt pthread crypt util xnet resolv dl
EMPTY_LIBS = $(EMPTY_LIB_NAMES:%=lib%.a)

all: $(EMPTY_LIBS)

$(EMPTY_LIBS):
	rm -f $@
	$(AR) rc $@

crt0.o: crt/crt1.c arch/$(ARCH)/crt_arch.h
	@mkdir -p out
	@printf "CC\t%s\n" "$@"
	@$(CC) $(CFLAGS) -c -o $@ $<

include/bits/alltypes.h: arch/$(ARCH)/bits/alltypes.h.in include/alltypes.h.in tools/mkalltypes.sed
	@mkdir -p out/include/bits
	@sed -f tools/mkalltypes.sed arch/$(ARCH)/bits/alltypes.h.in include/alltypes.h.in > $@

include/bits/syscall.h: arch/generic/bits/syscall.h.in
	cp $< $@
	sed -n -e s/__NR_/SYS_/p < $< >> $@

src/%.o: src/%.c include/bits/alltypes.h include/bits/syscall.h
	@mkdir -p $$(dirname $@)
	@printf "CC\t%s\n" "$@"
	@$(CC) $(CFLAGS) -c -o $@ $<

src/%.o: src/%.s
	@mkdir -p $$(dirname $@)
	@printf "CC\t%s\n" "$@"
	@$(CC) $(CFLAGS) -c -o $@ $<

src/%.o: src/%.S
	@mkdir -p $$(dirname $@)
	@printf "CC\t%s\n" "$@"
	@$(CC) $(CFLAGS) -c -o $@ $<

DIRS=\
     ctype \
     dirent \
     env \
     errno \
     exit \
     fcntl \
     internal \
     locale \
     malloc \
     math \
     misc \
     mman \
     multibyte \
     process \
     regex \
     setjmp \
     signal \
     stat \
     stdio \
     stdlib \
     string \
     time \
     unistd

OBJECTS = $(foreach dir,$(DIRS),$(patsubst %.c,%.o,$(wildcard src/$(dir)/*.c)))
OBJECTS += $(foreach dir,$(DIRS),$(patsubst %.c,%.o,$(wildcard src/$(dir)/$(ARCH)/*.c)))
OBJECTS += $(foreach dir,$(DIRS),$(patsubst %.S,%.o,$(wildcard src/$(dir)/$(ARCH)/*.S)))
OBJECTS += $(foreach dir,$(DIRS),$(patsubst %.s,%.o,$(wildcard src/$(dir)/$(ARCH)/*.s)))

libc.a: $(OBJECTS)
	@printf "AR\t%s\n" "$@"
	@$(AR) -csr $@ $^

install-headers: include/bits/alltypes.h
	mkdir -p $(DESTDIR)$(INCLUDEDIR)
	mkdir -p $(DESTDIR)$(INCLUDEDIR)/bits
	mkdir -p $(DESTDIR)$(INCLUDEDIR)/sys
	install -Dm644 include/*.h $(DESTDIR)$(INCLUDEDIR)
	install -Dm644 include/sys/*.h $(DESTDIR)$(INCLUDEDIR)/sys
	install -Dm644 arch/$(ARCH)/bits/*.h $(DESTDIR)$(INCLUDEDIR)/bits
	install -Dm644 arch/generic/bits/*.h $(DESTDIR)$(INCLUDEDIR)/bits
	install -Dm644 include/bits/*.h $(DESTDIR)$(INCLUDEDIR)/bits

install-libc: libc.a crt0.o $(EMPTY_LIBS)
	mkdir -p $(DESTDIR)$(LIBDIR)
	install -Dm644 crt0.o $(DESTDIR)$(LIBDIR)
	install -Dm644 libc.a $(DESTDIR)$(LIBDIR)
	for lib in $(EMPTY_LIBS); do \
		install -Dm644 $$lib $(DESTDIR)$(LIBDIR); \
	done

install: install-headers install-libc

clean:
	rm -rf libc.a
	find . -name '*.o' -delete

.PHONY: install-headers install-libc install clean
