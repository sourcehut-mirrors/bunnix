export type wq_link = struct {
	next: nullable *wq_link,
};

export type wq_head = struct {
	next: nullable *wq_link,
};
