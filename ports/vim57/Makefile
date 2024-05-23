INCS=-I. -Iproto -DHAVE_CONFIG_H
CFLAGS=$(INCS) -DHAVE_CONFIG_H -O -DMIN_FEAT -DWANT_EVAL
LIBS=-ltermcap
CC=x86_64-bunnix-gcc

OBJS=buffer.o charset.o digraph.o edit.o eval.o ex_cmds.o \
    ex_docmd.o ex_getln.o fileio.o getchar.o if_cscope.o \
    main.o mark.o memfile.o memline.o menu.o message.o \
    misc1.o misc2.o multbyte.o normal.o ops.o option.o \
    os_unix.o pathdef.o quickfix.o regexp.o screen.o search.o \
    syntax.o tag.o term.o ui.o undo.o window.o version.o

vim: $(OBJS)
	$(CC) $(CFLAGS) -o vim $(OBJS) $(LIBS)
clean:
	rm -f $(OBJS)
clobber: clean
	rm -f vim
