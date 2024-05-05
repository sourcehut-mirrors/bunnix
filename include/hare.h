#ifndef HARE_H
#define HARE_H

// Hare slice
struct slice {
	// The slice contents.
	void *data;
	// The number of members of the slice.
	size_t length;
	// The allocate capacity (in members) of data.
	size_t capacity;
};

// Hare str
struct string {
	// The string contents, UTF-8.
	char *data;
	// The number of members of the slice.
	size_t length;
	// The allocate capacity (in members) of data.
	size_t capacity;
};

#endif
