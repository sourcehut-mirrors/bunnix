use log;

const PCI: str = "pci";

// PCI driver probe implementation.
export type fn_probe = fn(info: *probe_info) nullable *pcidev;

// Info provided to fn_probe.
export type probe_info = struct {
	bus: *pcibus,
	device: u32,
};

// PCI driver implementation.
export type driver = struct {
	name: const str,
	class: u16,
	probe: *fn_probe,
	next: nullable *driver,
};

let drivers_head: nullable *driver = null;
let devices: []*pcidev = [];

// Registers a PCI device driver.
export fn register_driver(driver: *driver) void = {
	driver.next = drivers_head;
	drivers_head = driver;
};

// Probe a PCI device for its driver, if any.
export fn probe(bus: *pcibus, device: u32) void = {
	const info = probe_info {
		bus = bus,
		device = device,
	};
	const class = read_type(bus, device);

	let cur = drivers_head;
	for (cur != null; cur = (cur: *driver).next) {
		const cur = cur: *driver;
		if (cur.class == class) {
			break;
		};
	};
	if (cur == null) {
		return;
	};

	const driver = cur: *driver;
	const bus = device_bus(device);
	const slot = device_slot(device);
	const func = device_func(device);
	const (class, subclass) = class_lookup(class);
	log::kprintfln(PCI, "{:x}:{:x}.{} {} {}: driver '{}'",
		bus, slot, func, class, subclass, driver.name);

	match (driver.probe(&info)) {
	case null => return;
	case let dev: *pcidev =>
		append(devices, dev)!;
	};
};
