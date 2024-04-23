// Block device interface
export type interface = enum uint {
	SATA,
	ATAPI,
	NVME,

	// Internal use
	BLOCKPART,
};

let serials: [_]uint = [
	0,	// SATA
	0,	// ATAPI
	0,	// NVME
];

// Returns a human-friendly representation of [[interface]].
export fn iface_str(iface: interface) const str = {
	switch (iface) {
	case interface::SATA =>
		return "sata";
	case interface::ATAPI =>
		return "atapi";
	case interface::NVME =>
		return "nvme";
	case interface::BLOCKPART =>
		return "[part]";
	};
};
