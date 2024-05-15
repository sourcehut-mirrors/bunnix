all:

ROOT=../
include $(ROOT)mk/conf.mk

install-sbin:
	for f in $^; \
	do install -Dm755 "$$f" $(DESTDIR)/sbin; \
	done

install: install-sbin

clean:

.PHONY: install install-sbin clean

HAREPROGS=\
	getty \
	init \
	mount

define hare_prog
$1/$1: $(wildcard $1/*.ha) $$(HARE_SOURCES)
	$(HAREBUILD) -o $1/$1 $1/

all: $1/$1
install-sbin: $1/$1

clean-$1:
	rm -f $1/$1
clean: clean-$1

.PHONY: clean-$1
endef

$(foreach prog,$(HAREPROGS),$(eval $(call hare_prog,$(prog))))
