fn isr_return(rsp: uintptr) never;

export fn enter_user(ctx: *context) never = {
	isr_return(ctx: uintptr);
};
