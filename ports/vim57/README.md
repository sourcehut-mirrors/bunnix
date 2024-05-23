This is a snapshot of vim, version 5.7.  The source organization--
and in particular, the Makefile--have been greatly streamlined.  What
is left is just the source and Makefile to build vim, in as simple
a fashion as possible.  In time I may shed the myriad maze of ifdef's
which make the code needlessly hard to read.

As vim has marched forward, I found myself forever having to spend
time fending off the endless list of "conveniences" which were
sprung upon me at each new release.  I finally punted and picked a
version of vim which had what I wanted, and little of what I
did not want.  With a nod, I departed the "vim express".

On any sort of run-of-the-mill Linux-ish system, you should be
able to just type "make" and get a "vim" binary.  The only gotcha
I've hit is the terminal handling library.  It may be -ltermcap,
or -lncurses, or -lncursesw, somthing like that.

As a snapshot, the original vim license is fully in effect.  I've
included a copy here under LICENSE.txt.
