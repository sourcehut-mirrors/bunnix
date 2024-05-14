LIBVTERM_DIR=$(ROOT)vendor/libvterm/src
LIBVTERM_OBJ=\
	$(LIBVTERM_DIR)/encoding.o \
	$(LIBVTERM_DIR)/keyboard.o \
	$(LIBVTERM_DIR)/mouse.o \
	$(LIBVTERM_DIR)/parser.o \
	$(LIBVTERM_DIR)/pen.o \
	$(LIBVTERM_DIR)/screen.o \
	$(LIBVTERM_DIR)/state.o \
	$(LIBVTERM_DIR)/unicode.o \
	$(LIBVTERM_DIR)/vterm.o

CFLAGS+=-I$(ROOT)vendor/libvterm/include/ -I$(ROOT)/vendor/libvterm/src/ -g

$(ROOT)sys/lib/vterm/libvterm.a: $(LIBVTERM_OBJ)
	$(AR) -crv $@ $(LIBVTERM_OBJ)

LIB_LIBVTERM_TARGET=$(ROOT)sys/lib/vterm/libvterm.a
LIB_LIBVTERM=-L$(ROOT)sys/lib/vterm/ -lvterm

clean-libvterm:
	rm -f $(LIBVTERM_OBJ) $(ROOT)lib/vterm/libvterm.a

clean: clean-libvterm
