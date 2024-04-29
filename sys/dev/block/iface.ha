// Block device interface
export type interface = enum uint {
	UNKNOWN,
	SATA,
	ATAPI,
	NVME,

	// Internal use
	BLOCKPART,
};

let serials: [_]uint = [
	0,	// UNKNOWN (not used)
	0,	// SATA
	0,	// ATAPI
	0,	// NVME
];

// Returns a human-friendly representation of [[interface]].
export fn iface_str(iface: interface) const str = {
	switch (iface) {
	case interface::UNKNOWN =>
		return "unknown";
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

// Returns an [[interface]] by name.
export fn str_iface(name: str) interface = {
	switch (name) {
	case "sata" =>
		return interface::SATA;
	case "atapi" =>
		return interface::ATAPI;
	case "nvme" =>
		return interface::NVME;
	case =>
		return interface::UNKNOWN;
	};
};
