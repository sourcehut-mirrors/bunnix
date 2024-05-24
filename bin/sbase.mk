SBASE=$(ROOT)/vendor/sbase
SBASE_SOURCES=$(call rwildcard,$(SBASE),*.c *.h)

clean-sbase:
	make -C $(SBASE) clean

.PHONY: clean-sbase

clean: clean-sbase

SBASE_PROGS=\
	$(SBASE)/basename \
	$(SBASE)/cal \
	$(SBASE)/cat \
	$(SBASE)/chgrp \
	$(SBASE)/chmod \
	$(SBASE)/chown \
	$(SBASE)/chroot \
	$(SBASE)/cksum \
	$(SBASE)/cmp \
	$(SBASE)/comm \
	$(SBASE)/cp \
	$(SBASE)/cut \
	$(SBASE)/date \
	$(SBASE)/dd \
	$(SBASE)/dirname \
	$(SBASE)/du \
	$(SBASE)/echo \
	$(SBASE)/ed \
	$(SBASE)/env \
	$(SBASE)/expand \
	$(SBASE)/expr \
	$(SBASE)/false \
	$(SBASE)/find \
	$(SBASE)/flock \
	$(SBASE)/fold \
	$(SBASE)/getconf \
	$(SBASE)/grep \
	$(SBASE)/head \
	$(SBASE)/hostname \
	$(SBASE)/join \
	$(SBASE)/kill \
	$(SBASE)/link \
	$(SBASE)/ln \
	$(SBASE)/logname \
	$(SBASE)/ls \
	$(SBASE)/md5sum \
	$(SBASE)/mkdir \
	$(SBASE)/mkfifo \
	$(SBASE)/mknod \
	$(SBASE)/mktemp \
	$(SBASE)/mv \
	$(SBASE)/nl \
	$(SBASE)/nohup \
	$(SBASE)/od \
	$(SBASE)/paste \
	$(SBASE)/pathchk \
	$(SBASE)/printenv \
	$(SBASE)/printf \
	$(SBASE)/pwd \
	$(SBASE)/readlink \
	$(SBASE)/rev \
	$(SBASE)/rm \
	$(SBASE)/rmdir \
	$(SBASE)/sed \
	$(SBASE)/seq \
	$(SBASE)/setsid \
	$(SBASE)/sha1sum \
	$(SBASE)/sha224sum \
	$(SBASE)/sha256sum \
	$(SBASE)/sha384sum \
	$(SBASE)/sha512sum \
	$(SBASE)/sha512-224sum \
	$(SBASE)/sha512-256sum \
	$(SBASE)/sleep \
	$(SBASE)/sort \
	$(SBASE)/split \
	$(SBASE)/sponge \
	$(SBASE)/strings \
	$(SBASE)/sync \
	$(SBASE)/tail \
	$(SBASE)/tar \
	$(SBASE)/tee \
	$(SBASE)/test \
	$(SBASE)/touch \
	$(SBASE)/tr \
	$(SBASE)/true \
	$(SBASE)/tsort \
	$(SBASE)/tty \
	$(SBASE)/uname \
	$(SBASE)/unexpand \
	$(SBASE)/uniq \
	$(SBASE)/unlink \
	$(SBASE)/uudecode \
	$(SBASE)/uuencode \
	$(SBASE)/wc \
	$(SBASE)/which \
	$(SBASE)/whoami \
	$(SBASE)/xargs \
	$(SBASE)/xinstall \
	$(SBASE)/yes

install-bin: $(SBASE_PROGS)

SBASE_MAKEVARS=CC=$(CC) AR=$(AR) RANTOOL=$(RANTOOL)

$(SBASE)/libutf.a: $(SBASE_SOURCES)
	make -C $(SBASE) libutf.a $(SBASE_MAKEVARS)

$(SBASE)/libutil.a: $(SBASE_SOURCES)
	make -C $(SBASE) libutil.a $(SBASE_MAKEVARS)

SBASE_LIBS=$(SBASE)/libutf.a $(SBASE)/libutil.a

define sbase_prog
$1: $(SBASE_SOURCES) $(SBASE_LIBS) $(SYSROOT)/usr/lib/libc.a
	make -C $(SBASE) $(shell basename $1) $(SBASE_MAKEVARS)

install-man: $1.1

all: $1
endef

$(foreach prog,$(SBASE_PROGS),$(eval $(call sbase_prog,$(prog))))
