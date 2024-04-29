// lwext4/include/misc/*
// Simple shims for the macros therein

export type rb_head = struct {
	rbh_root: nullable *opaque,
};

export type rb_entry = struct {
	rbe_left: nullable *opaque,
	rbe_right: nullable *opaque,
	rbe_parent: nullable *opaque,
	rbe_color: int,
};

export type tailq_head = struct {
	tqh_first: nullable *opaque,
	tqh_last: nullable **opaque,
};

export type tailq_entry = struct {
	tqe_next: nullable *opaque,
	tqe_prev: nullable **opaque,
};

export type list_head = struct {
	le_first: nullable *opaque,
};

export type list_entry = struct {
	le_next: nullable *opaque,
	le_prev: nullable **opaque,
};

export type slist_head = struct {
	slh_first: nullable *opaque,
};

export type slist_entry = struct {
	slh_next: nullable *opaque,
};
