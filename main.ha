use arch::main;		// link
use arch_dev = arch::dev;
use boot;
use dev;
use log;
use mman;
use rt;
// XXX TEMP
use dev::pci;

export fn main(ctx: *boot::context) void = {
	log::println("Bunnix kernel boot");
	log::printfln("command line: {}", ctx.cmdline);

	mman::init(ctx);

	arch_dev::init();
	dev::scan();
	pci::scan(&arch_dev::legacy_pci_bus, &pci_enum, null);

	log::println("Nothing to do; idling");
	rt::halt();
};

fn pci_enum(dev: *pci::pcidev, device: u32, user: nullable *opaque) void = {
	const bus = pci::device_bus(device);
	const slot = pci::device_bus(device);
	const func = pci::device_func(device);
	const class = pci::read_type(dev, device);
	const (class, subclass) = pci::class_lookup(class);
	log::printfln("{:x}:{:x}.{} {} {}",
		bus, slot, func, class, subclass);
};
