// See ext4_bcache.h

export type buf = opaque;

export type bcache = opaque;

export type block = struct {
	lb_id: u64,
	buf: nullable *buf,
	data: nullable *u8,
};
