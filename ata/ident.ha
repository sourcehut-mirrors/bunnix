use endian;
use log;
use strings;

// Device identification
export type ident = struct {
	serial_buf: [20]u8,
	firmware_buf: [8]u8,
	model_buf: [40]u8,

	serial: str,
	firmware: str,
	model: str,

	sectors: size,
};

// Decodes ATA IDENTIFY packet response into useful bits.
export fn decode_ident(buf: []u8, id: *ident) void = {
	assert(len(buf) >= 512);
	const buf = buf: *[*]u8: *[256]u16;
	id.serial = decode_idstr(buf[10..20], id.serial_buf);
	id.firmware = decode_idstr(buf[23..27], id.firmware_buf);
	id.model = decode_idstr(buf[27..47], id.model_buf);

	const css = gbit16(&buf[83]);
	const has48 = css & (1 << 10) != 0;
	if (has48) {
		id.sectors = gbit64(&buf[100]);
	} else {
		id.sectors = gbit32(&buf[60]);
	};

	// TODO: Maybe report errors properly instead of crashing your driver
	assert(id.sectors != 0, "ATA IDENTIFY issue, old drive?");
};

fn gbit16(v: *u16) u16 = {
	const i = v: *[*]u8;
	let j = i[1] << 8u16;
	j |= i[0];
	return j;
};

fn gbit32(v: *u16) u32 = {
	const i = v: *[*]u8;
	let j = i[3] << 24u32;
	j |= i[2] << 16u32;
	j |= i[1] << 8u32;
	j |= i[0];
	return j;
};

fn gbit64(v: *u16) u64 = {
	let v = v: *[*]u16;
	return gbit32(&v[1]) << 32 | gbit32(&v[0]);
};

fn decode_idstr(in: []u16, buf: []u8) str = {
	const i = in: *[*]u8;
	const in = i[..len(in) * 2];

	let out = buf[..0];
	for (let i = 0z; i < len(in); i += 2) {
		static append(out, in[i + 1]);
		static append(out, in[i + 0]);
	};

	return strings::rtrim(strings::fromutf8(out)!);
};
