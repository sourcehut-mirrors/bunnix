// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use ascii;

// Outputs a dump of hex data alongside the offset and an ASCII representation
// (if applicable).
//
// Example output:
//
// 	00000000  7f 45 4c 46 02 01 01 00  00 00 00 00 00 00 00 00  |.ELF............|
// 	00000010  03 00 3e 00 01 00 00 00  80 70 01 00 00 00 00 00  |..>......p......|
export fn dump(data: []u8, addr: u64 = 0) void = {
	let datalen = len(data): u64;

	for (let off = addr; off < datalen; off += 16) {
		printf("{:.8x}  ", off);

		let toff = 0z;
		for (let i = 0u64; i < 16 && off + i < datalen; i += 1) {
			let val = data[off + i];
			toff += printf("{}{:.2x} ",
				if (i == 8) " " else "", val);
		};

		// Align ASCII representation, max width of hex part (48) +
		// spacing around it
		for (toff < 50; toff += 1) {
			print(" ");
		};

		print("|");
		for (let i = 0u64; i < 16 && off + i < datalen; i += 1) {
			let r = data[off + i]: rune;

			print(if (ascii::isprint(r)) r else '.');
		};
		print("|\n");
	};
};
