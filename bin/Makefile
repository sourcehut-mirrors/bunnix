all:

ROOT=../
include $(ROOT)mk/conf.mk

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
