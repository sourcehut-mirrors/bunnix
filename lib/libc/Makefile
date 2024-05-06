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
	 -Wno-implicit-fallthrough -Wno-dangling-pointer
CFLAGS += -D_XOPEN_SOURCE=700 -Isrc/include/ -Isrc/internal/ -Iout/include/ -Iarch/$(ARCH)/ -Iarch/generic/ -Iinclude/
LDFLAGS = -Wl,--sort-section,alignment -Wl,--sort-common -Wl,--gc-sections -Wl,--hash-style=both -Wl,--no-undefined -Wl,--exclude-libs=ALL

crt0.o: crt/crt1.c arch/$(ARCH)/crt_arch.h
	@mkdir -p out
	@printf "CC\t%s\n" "$@"
	@$(CC) $(CFLAGS) -c -o $@ $<

out/include/bits/alltypes.h: arch/$(ARCH)/bits/alltypes.h.in include/alltypes.h.in tools/mkalltypes.sed
	@mkdir -p out/include/bits
	@sed -f tools/mkalltypes.sed arch/$(ARCH)/bits/alltypes.h.in include/alltypes.h.in > $@

out/src/%.o: src/%.c out/include/bits/alltypes.h
	@mkdir -p $$(dirname $@)
	@printf "CC\t%s\n" "$@"
	@$(CC) $(CFLAGS) -c -o $@ $<

out/src/%.o: src/%.s
	@mkdir -p $$(dirname $@)
	@printf "CC\t%s\n" "$@"
	@$(CC) $(CFLAGS) -c -o $@ $<

CTYPE_OBJECTS=\
	out/src/ctype/__ctype_b_loc.o \
	out/src/ctype/__ctype_get_mb_cur_max.o \
	out/src/ctype/__ctype_tolower_loc.o \
	out/src/ctype/__ctype_toupper_loc.o \
	out/src/ctype/isalnum.o \
	out/src/ctype/isalpha.o \
	out/src/ctype/isascii.o \
	out/src/ctype/isblank.o \
	out/src/ctype/iscntrl.o \
	out/src/ctype/isdigit.o \
	out/src/ctype/isgraph.o \
	out/src/ctype/islower.o \
	out/src/ctype/isprint.o \
	out/src/ctype/ispunct.o \
	out/src/ctype/isspace.o \
	out/src/ctype/isupper.o \
	out/src/ctype/iswalnum.o \
	out/src/ctype/iswalpha.o \
	out/src/ctype/iswblank.o \
	out/src/ctype/iswcntrl.o \
	out/src/ctype/iswctype.o \
	out/src/ctype/iswdigit.o \
	out/src/ctype/iswgraph.o \
	out/src/ctype/iswlower.o \
	out/src/ctype/iswprint.o \
	out/src/ctype/iswpunct.o \
	out/src/ctype/iswspace.o \
	out/src/ctype/iswupper.o \
	out/src/ctype/iswxdigit.o \
	out/src/ctype/isxdigit.o \
	out/src/ctype/toascii.o \
	out/src/ctype/tolower.o \
	out/src/ctype/toupper.o \
	out/src/ctype/towctrans.o \
	out/src/ctype/wcswidth.o \
	out/src/ctype/wctrans.o \
	out/src/ctype/wcwidth.o

OBJECTS=\
	$(CTYPE_OBJECTS)

libc.a: $(OBJECTS)
	@printf "AR\t%s\n" "$@"
	@$(AR) -csr $@ $^

install-headers: out/include/bits/alltypes.h
	mkdir -p $(DESTDIR)$(INCLUDEDIR)
	mkdir -p $(DESTDIR)$(INCLUDEDIR)/bits
	mkdir -p $(DESTDIR)$(INCLUDEDIR)/sys
	install -Dm644 include/*.h $(DESTDIR)$(INCLUDEDIR)
	install -Dm644 include/sys/*.h $(DESTDIR)$(INCLUDEDIR)/sys
	install -Dm644 arch/$(ARCH)/bits/*.h $(DESTDIR)$(INCLUDEDIR)/bits
	install -Dm644 arch/generic/bits/*.h $(DESTDIR)$(INCLUDEDIR)/bits
	install -Dm644 out/include/bits/*.h $(DESTDIR)$(INCLUDEDIR)/bits

install-libc: libc.a crt0.o
	mkdir -p $(DESTDIR)$(LIBDIR)
	install -Dm644 crt0.o $(DESTDIR)$(LIBDIR)
	install -Dm644 libc.a $(DESTDIR)$(LIBDIR)

install: install-headers install-libc

clean:
	rm -rf out libc.a

.PHONY: install-headers install-libc install clean
