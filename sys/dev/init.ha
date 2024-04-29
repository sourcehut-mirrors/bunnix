use log;

// Scan all buses for devices.
export fn scan() void = {
	for (let bus .. buses) {
		bus_scan(bus);
	};
};
