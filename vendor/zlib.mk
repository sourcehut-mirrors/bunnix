ZLIB_DIR=$(ROOT)/vendor/zlib
ZLIB_OBJ=$(wildcard $(ZLIB_DIR)/*.c)
ZLIB_OBJ+=$(wildcard $(ZLIB_DIR)/*.h)

$(ROOT)/vendor/zlib/libz.a: $(ZLIB_OBJ)
	cd $(ROOT)/vendor/zlib && CHOST=$(EFI_TRIPLET) \
		./configure --static --solo
	make -C $(ROOT)/vendor/zlib

LIBZ_TARGET=$(ROOT)/vendor/zlib/libz.a
LIBZ=-L$(ROOT)/vendor/zlib/ -lz

clean-zlib:
	make -C $(ROOT)/vendor/zlib clean || true

clean: clean-zlib
