export fn memcpy(dest: *[*]u8, src: *[*]u8, amt: size) void = {
        for (let i = 0z; i < amt; i += 1) {
                dest[i] = src[i];
        };
};
