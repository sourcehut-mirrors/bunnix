// A device bus.
export type bus = struct {
	bus: *bus_iface,
};

// Scan the bus for devices.
export type fn_bus_scan = fn(bus: *bus) void;

// Interface for a device bus.
export type bus_iface = struct {
	scan: *fn_bus_scan,
};

// Scans a device bus.
export fn bus_scan(bus: *bus) void = {
	bus.bus.scan(bus);
};
