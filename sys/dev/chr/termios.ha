// termios structure
export type termios = struct {
	c_iflag: uint,
	c_oflag: uint,
	c_cflag: uint,
	c_lflag: uint,
	c_cc: [32]u8,
};

export type winsize = struct {
	ws_row: u16,
	ws_col: u16,
};

export fn termios_init(tios: *termios) void = {
	tios.c_iflag = BRKINT | ISTRIP | ICRNL | IMAXBEL | IXON | IXANY;
	tios.c_oflag = OPOST | ONLCR;
	tios.c_lflag = ECHO | ICANON | ISIG | IEXTEN;
	tios.c_cflag = CREAD | CS7 | PARENB | HUPCL;
};

export def VINTR	= 0;
export def VQUIT	= 1;
export def VERASE	= 2;
export def VKILL	= 3;
export def VEOF		= 4;
export def VTIME	= 5;
export def VMIN		= 6;
export def VSWTC	= 7;
export def VSTART	= 8;
export def VSTOP	= 9;
export def VSUSP	= 10;
export def VEOL		= 11;
export def VREPRINT	= 12;
export def VDISCARD	= 13;
export def VWERASE	= 14;
export def VLNEXT	= 15;
export def VEOL2	= 16;

export def IGNBRK	= 0o0000001;
export def BRKINT	= 0o0000002;
export def IGNPAR	= 0o0000004;
export def PARMRK	= 0o0000010;
export def INPCK	= 0o0000020;
export def ISTRIP	= 0o0000040;
export def INLCR	= 0o0000100;
export def IGNCR	= 0o0000200;
export def ICRNL	= 0o0000400;
export def IUCLC	= 0o0001000;
export def IXON		= 0o0002000;
export def IXANY	= 0o0004000;
export def IXOFF	= 0o0010000;
export def IMAXBEL	= 0o0020000;
export def IUTF8	= 0o0040000;

export def OPOST	= 0o0000001;
export def OLCUC	= 0o0000002;
export def ONLCR	= 0o0000004;
export def OCRNL	= 0o0000010;
export def ONOCR	= 0o0000020;
export def ONLRET	= 0o0000040;
export def OFILL	= 0o0000100;
export def OFDEL	= 0o0000200;

export def VTDLY	= 0o0040000;
export def VT0		= 0o0000000;
export def VT1		= 0o0040000;

export def B0		= 0o0000000;
export def B50		= 0o0000001;
export def B75		= 0o0000002;
export def B110		= 0o0000003;
export def B134		= 0o0000004;
export def B150		= 0o0000005;
export def B200		= 0o0000006;
export def B300		= 0o0000007;
export def B600		= 0o0000010;
export def B1200	= 0o0000011;
export def B1800	= 0o0000012;
export def B2400	= 0o0000013;
export def B4800	= 0o0000014;
export def B9600	= 0o0000015;
export def B19200	= 0o0000016;
export def B38400	= 0o0000017;

export def B57600	= 0o0010001;
export def B115200	= 0o0010002;
export def B230400	= 0o0010003;
export def B460800	= 0o0010004;
export def B500000	= 0o0010005;
export def B576000	= 0o0010006;
export def B921600	= 0o0010007;
export def B1000000	= 0o0010010;
export def B1152000	= 0o0010011;
export def B1500000	= 0o0010012;
export def B2000000	= 0o0010013;
export def B2500000	= 0o0010014;
export def B3000000	= 0o0010015;
export def B3500000	= 0o0010016;
export def B4000000	= 0o0010017;

export def CSIZE	= 0o0000060;
export def CS5		= 0o0000000;
export def CS6		= 0o0000020;
export def CS7		= 0o0000040;
export def CS8		= 0o0000060;
export def CSTOPB	= 0o0000100;
export def CREAD	= 0o0000200;
export def PARENB	= 0o0000400;
export def PARODD	= 0o0001000;
export def HUPCL	= 0o0002000;
export def CLOCAL	= 0o0004000;

export def ISIG		= 0o0000001;
export def ICANON	= 0o0000002;
export def ECHO		= 0o0000010;
export def ECHOE	= 0o0000020;
export def ECHOK	= 0o0000040;
export def ECHONL	= 0o0000100;
export def NOFLSH	= 0o0000200;
export def TOSTOP	= 0o0000400;
export def IEXTEN	= 0o0100000;

export def TCOOFF	= 0o0;
export def TCOON	= 0o1;
export def TCIOFF	= 0o2;
export def TCION	= 0o3;

export def TCIFLUSH	= 0o0;
export def TCOFLUSH	= 0o1;
export def TCIOFLUSH	= 0o2;

export def TCSANOW	= 0o0;
export def TCSADRAIN	= 0o1;
export def TCSAFLUSH	= 0o2;
