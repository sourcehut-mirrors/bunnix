#include <stdlib.h>
#include <string.h>
#include "malloc_impl.h"

void *realloc(void *ptr, size_t size) {
	void *new = malloc(size);
	if (!new || !ptr) {
		return new;
	}
	size_t oldsz = (size_t)(((size_t *)ptr)[-1]);
	memcpy(new, ptr, oldsz);
	free(ptr);
	return new;
}
