all:

ROOT=../
include $(ROOT)mk/conf.mk

# BEGIN C TEST CODE
test-c/main.o: $(SYSROOT)/usr/lib/libc.a
	$(USER_CBUILD) -g -c -o $@ test-c/main.c

test-c/test-c: $(SYSROOT)/usr/lib/libc.a test-c/main.o
	$(USER_CBUILD) -o $@ test-c/main.o

all: test-c/test-c
install-bin: test-c/test-c
clean-test-c:
	rm -f test-c/test-c
clean: clean-test-c
# EOF

HAREPROGS=\
	echo \
	env \
	init

install-bin:
	for f in $^; \
	do install -Dm755 "$$f" $(DESTDIR)/bin; \
	done

install: install-bin

clean:

.PHONY: install install-bin clean

define hare_prog
$1/$1: $(wildcard $1/*.ha) $$(HARE_SOURCES)
	$(HAREBUILD) -o $1/$1 $1/

all: $1/$1
install-bin: $1/$1

clean-$1:
	rm -f $1/$1
clean: clean-$1

.PHONY: clean-$1
endef

$(foreach prog,$(HAREPROGS),$(eval $(call hare_prog,$(prog))))
