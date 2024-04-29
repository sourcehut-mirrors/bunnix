LWEXT4_DIR=$(ROOT)vendor/lwext4/src
LWEXT4_OBJ=\
	$(LWEXT4_DIR)/ext4.o \
	$(LWEXT4_DIR)/ext4_balloc.o \
	$(LWEXT4_DIR)/ext4_bcache.o \
	$(LWEXT4_DIR)/ext4_bitmap.o \
	$(LWEXT4_DIR)/ext4_block_group.o \
	$(LWEXT4_DIR)/ext4_blockdev.o \
	$(LWEXT4_DIR)/ext4_crc32.o \
	$(LWEXT4_DIR)/ext4_debug.o \
	$(LWEXT4_DIR)/ext4_dir.o \
	$(LWEXT4_DIR)/ext4_dir_idx.o \
	$(LWEXT4_DIR)/ext4_extent.o \
	$(LWEXT4_DIR)/ext4_fs.o \
	$(LWEXT4_DIR)/ext4_hash.o \
	$(LWEXT4_DIR)/ext4_ialloc.o \
	$(LWEXT4_DIR)/ext4_inode.o \
	$(LWEXT4_DIR)/ext4_journal.o \
	$(LWEXT4_DIR)/ext4_mbr.o \
	$(LWEXT4_DIR)/ext4_mkfs.o \
	$(LWEXT4_DIR)/ext4_super.o \
	$(LWEXT4_DIR)/ext4_trans.o \
	$(LWEXT4_DIR)/ext4_xattr.o

CFLAGS+=-I$(ROOT)vendor/lwext4/include/ -DCONFIG_USE_DEFAULT_CFG

$(ROOT)sys/lib/lwext4/liblwext4.a: $(LWEXT4_OBJ)
	$(AR) -crv $@ $(LWEXT4_OBJ)

LIB_LWEXT4_TARGET=$(ROOT)sys/lib/lwext4/liblwext4.a
LIB_LWEXT4=-L$(ROOT)sys/lib/lwext4/ -llwext4

clean-lwext4:
	rm -f $(LWEXT4_OBJ) $(ROOT)lib/lwext4/liblwext4.a

clean: clean-lwext4
