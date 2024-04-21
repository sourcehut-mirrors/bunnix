use log;

export fn isr_handler(ctx: *context) *context = {
	const intno = ctx.intno: u8;
	log::printfln("INT {}", intno);
	return ctx;
};
