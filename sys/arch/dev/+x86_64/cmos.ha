use arch;
use arch::x86_64;
use time;

let boot_tsc: u64 = 0;

def CMOS_ADDR: u16 = 0x70;
def CMOS_DATA: u16 = 0x71;

type cmos_time = struct {
	sec: u8,
	min: u8,
	hour: u8,
	day: u8,
	month: u8,
	year: u8,
	century: u8,
	mode: cmos_mode,
	format: cmos_format,
};

type cmos_mode = enum {
	BIN,
	BCD,
};

type cmos_format = enum {
	TWELVE,
	TWENTYFOUR,
};

fn cmos_init() void = {
	boot_tsc = arch::gettime();

	let time = cmos_time { ... };
	cmos_read_time(&time);

	if (time.mode == cmos_mode::BCD) {
		time.sec = bcdtobin(time.sec);
		time.min = bcdtobin(time.min);
		time.hour = bcdtobin(time.hour);
		time.day = bcdtobin(time.day);
		time.month = bcdtobin(time.month);
		time.year = bcdtobin(time.year);
		time.century = bcdtobin(time.century);
	};

	let year = time.year: uint;
	if (time.century > 19) {
		year += (time.century - 19) * 100;
	};
	if (year <= 69) {
		year += 100;
	};

	const unix = rtc_to_unix(
		year + 1900,
		time.month,
		time.day,
		time.hour,
		time.min,
		time.sec,
	);
	time::set_basis(unix, boot_tsc);
};

fn cmos_read(reg: u8) u8 = {
	const nmi = x86_64::inb(CMOS_ADDR) & 0x80;
	x86_64::outb(CMOS_ADDR, reg | nmi);
	return x86_64::inb(CMOS_DATA);
};

fn cmos_write(reg: u8, val: u8) void = {
	const nmi = x86_64::inb(CMOS_ADDR) & 0x80;
	x86_64::outb(CMOS_ADDR, reg | nmi);
	x86_64::outb(CMOS_DATA, val);
};

fn cmos_read_mode() cmos_mode = {
	const b = cmos_read(0x0B);
	if (b & 4 != 0) {
		return cmos_mode::BIN;
	};
	return cmos_mode::BCD;
};

fn cmos_read_fmt() cmos_format = {
	const b = cmos_read(0x0B);
	if (b & 2 != 0) {
		return cmos_format::TWENTYFOUR;
	};
	return cmos_format::TWELVE;
};

fn cmos_read_time(time: *cmos_time) void = {
	time.mode = cmos_read_mode();
	time.format = cmos_read_fmt();

	// Wait for any in-progress update to complete
	for (true) {
		if (cmos_read(0x0A) & (1 << 7) == 0) {
			break;
		};
	};

	time.sec = cmos_read(0x00);
	time.min = cmos_read(0x02);
	time.hour = cmos_read(0x04);
	time.day = cmos_read(0x07);
	time.month = cmos_read(0x08);
	time.year = cmos_read(0x09);
	time.century = cmos_read(0x32);
};

fn bcdtobin(value: u8) u8 = {
	return ((value & 0xF0) >> 1) + ((value & 0xF0) >> 3) + (value & 0xF);
};

fn bintobcd(value: u8) u8 = {
	let new = value: u16;

	for (let i = 0; i < 8; i = i+1) {
		if ((new & 0xF000) >> 12 >= 5) {
			new = new + 0x3000;
		};
		if ((new & 0x0F00) >> 8 >= 5) {
			new = new + 0x300;
		};
		new = new << 1;
	};

	return (new >> 8): u8;
};

// Adapted from Linux, kernel/time/time.c
fn rtc_to_unix(
	year0: uint, mon0: uint,
	day: uint, hour: uint,
	min: uint, sec: uint,
) u64 = {
	let mon = mon0, year = year0;

	// 1..12 -> 11,12,1..10
	mon -= 2;
	if (0 >= mon: int) {
		mon += 12; // Puts Feb last since it has leap day
		year -= 1;
	};

	return ((((
		  (year/4 - year/100 + year/400 + 367*mon/12 + day) +
		  year*365 - 719499
	    )*24 + hour		// now have hours - midnight tomorrow handled here
	  )*60 + min		// now have minutes
	)*60 + sec): u64;	// finally seconds
};
