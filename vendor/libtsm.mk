LIBTSM_DIR=$(ROOT)vendor/libtsm/src
LIBTSM_OBJ=\
	$(LIBTSM_DIR)/../external/wcwidth.o \
	$(LIBTSM_DIR)/shared/shl-htable.o \
	$(LIBTSM_DIR)/shared/shl-ring.o \
	$(LIBTSM_DIR)/tsm/tsm-render.o \
	$(LIBTSM_DIR)/tsm/tsm-screen.o \
	$(LIBTSM_DIR)/tsm/tsm-selection.o \
	$(LIBTSM_DIR)/tsm/tsm-unicode.o \
	$(LIBTSM_DIR)/tsm/tsm-vte-charsets.o \
	$(LIBTSM_DIR)/tsm/tsm-vte.o

CFLAGS+=\
	-I$(ROOT)vendor/libtsm/src/shared/ \
	-I$(ROOT)vendor/libtsm/src/tsm/ \
	-I$(ROOT)vendor/libtsm/

$(ROOT)sys/lib/tsm/libtsm.a: $(LIBTSM_OBJ)
	$(AR) -crv $@ $(LIBTSM_OBJ)

LIB_TSM_TARGET=$(ROOT)sys/lib/tsm/libtsm.a
LIB_TSM=-L$(ROOT)sys/lib/tsm/ -ltsm

clean-libtsm:
	rm -f $(LIBTSM_OBJ) $(ROOT)lib/tsm/libtsm.a

clean: clean-libtsm
