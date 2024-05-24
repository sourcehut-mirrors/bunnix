intro(1)

# NAME

intro - introduction to Bunnix

# DESCRIPTION

Welcome to the Bunnix operating system. This operating system was written in
about a month, just to see how far it could go. Bunnix is a Unix-like system
which includes a shell and a set of core utilities that should be familiar to
most Unix users.

The base system includes a POSIX-compatible shell (based on dash) and a set of
mostly POSIX-compatible core utilities for use with it.

Stuff should *mostly* work, though do keep in mind that this operating system
was written rather rapidly and has not been thoroughly tested, nor is the
documentation particularly impressive. If it crashes you can expect to reboot.

# THINGS TO DO ON BUNNIX

If you're curious to explore the system, here are a few things you can do.

## C PROGRAMMING

A suitable, somewhat POSIX-compatible C toolchain and the necessary headers are
installed in /usr, as well as GNU make. Both *vim* and *ed* are available as
text editors. Build your programs with *cc* and/or *make*.

## FILESYSTEMS

The Bunnix kernel includes *ext4* support. If you have an ext4 filesystem
installed on your filesystem, you may mount it with *mount -t ext4 <device>
<path>*, where <device> is e.g. */dev/sata0a*.

## GAMES

The following games are included:

*advent*
	Colossal Cave Adventure, one of the first text adventure games for Unix.
	To play, run *advent*.

*doom*
	The classic GPL release of DOOM is included in Bunnix, along with the
	freeware demo level (doom1.wad). Run *doom* to play.

Keep in mind that the default Bunnix environment is not persistent, so don't get
too attached to your save files.

## TERMINAL

Bunnix includes a more-or-less functional terminal emulator as /dev/tty0.
*lolcat* is included to make things colorful, and *less* is included as a pager.

If you wish to write your own terminal-aware programs, *curses* is available in
/usr. Build your programs with *-lcurses -lterminfo*.

# PERSISTENT INSTALL

It is possible to install Bunnix to disk and boot it without the iso. The exact
details are mostly left for the user to infer, but *boot*(7) may be of service.

# SOURCE CODE

If your distribution of Bunnix was configured to include the source code, the
full source code is available in /src for you to browse.

Note that Bunnix is not self-hosting, though you might have some luck getting
the included C toolchain to build some of the C software. The Hare toolchain,
binutils, and gcc are all known to work on Bunnix, but are not included; one may
build them for Bunnix and add them to the image to give self-hosting a shot - an
exercise left to the reader.
