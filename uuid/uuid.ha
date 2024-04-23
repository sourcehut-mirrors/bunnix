// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use bytes;
use strconv;
use strconv::{base};
use strings;

// A UUID.
export type uuid = [16]u8;

// The length of a UUID in bytes.
export def UUID_LEN: size = 16;

// The length of a UUID in runes when encoded as a string.
export def UUID_STRLEN: size = 36;

// The length of the return value of [[uri]] in runes.
export def UUID_URILEN: size = 45;

// The "nil" UUID, with all bits set to zero.
export const nil: uuid = [0...];

// Returned from [[decode]] if an invalid UUID is observed.
export type invalid = !void;

// Octet offsets of various fields as defined by the RFC.
def TIME_LOW: size = 0;
def TIME_MID: size = 4;
def TIME_HI_AND_VERSION: size = 6;
def CLOCK_SEQ_HI_AND_RESERVED: size = 8;
def CLOCK_SEQ_LOW: size = 9;
def NODE: size = 10;

// Returns true if two UUIDs are equal.
export fn compare(a: uuid, b: uuid) bool = bytes::equal(a, b);

fn hexconv(val: u8) []u8 = {
	static let buf: [8]u8 = [0...];
	const bytes = strings::toutf8(strconv::u8tos(val, base::HEX));
	let i = 0z;
	if (len(bytes) < 2) {
		buf[0] = '0';
		i += 1;
	};
	buf[i..i+len(bytes)] = bytes[..];
	return buf[..i+len(bytes)];
};

// Encodes a UUID as a string. The return value is statically allocated, the
// caller must use [[strings::dup]] to extend its lifetime.
export fn encodestr(in: uuid) str = {
	static let buf: [UUID_STRLEN]u8 = [0...];
	let buf = buf[..0];

	for (let i = TIME_LOW; i < TIME_LOW + 4; i += 1) {
		static append(buf, hexconv(in[i])...);
	};
	static append(buf, '-');
	for (let i = TIME_MID; i < TIME_MID + 2; i += 1) {
		static append(buf, hexconv(in[i])...);
	};
	static append(buf, '-');
	for (let i = TIME_HI_AND_VERSION; i < TIME_HI_AND_VERSION + 2; i += 1) {
		static append(buf, hexconv(in[i])...);
	};
	static append(buf, '-');
	static append(buf, hexconv(in[CLOCK_SEQ_HI_AND_RESERVED])...);
	static append(buf, hexconv(in[CLOCK_SEQ_LOW])...);
	static append(buf, '-');
	for (let i = NODE; i < NODE + 6; i += 1) {
		static append(buf, hexconv(in[i])...);
	};

	return strings::fromutf8_unsafe(buf);
};
