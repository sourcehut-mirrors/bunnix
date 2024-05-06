#include <stdlib.h>
#include <string.h>

void *realloc(void *ptr, size_t size) {
	void *new = malloc(size);
	if (!new || !ptr) {
		return new;
	}
	memcpy(new, ptr, size);
	free(ptr);
	return new;
}
