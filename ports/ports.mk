USR_BIN=\
	$(SYSROOT)/usr/bin/gzip

$(SYSROOT)/usr/bin: $(USR_BIN)

ports/build-gzip/gzip: $(SYSROOT)/usr/lib/libc.a
	mkdir -p ports/build-gzip/
	cd ports/build-gzip/ && ../gzip/configure \
		--prefix=/usr \
		--host=x86_64-bunnix
	cd ports/build-gzip && make

$(SYSROOT)/usr/bin/gzip: ports/build-gzip/gzip
	cd ports/build-gzip/ && make install DESTDIR="../../$(SYSROOT)"

clean-gzip:
	rm -rf ports/build-gzip

.PHONY: clean-gzip

clean-ports: clean-gzip

clean: clean-ports

.PHONY: clean-ports
