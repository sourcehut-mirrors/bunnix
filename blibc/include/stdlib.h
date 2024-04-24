#pragma once

void *malloc(size_t size);
void free(void *ptr);
void *calloc(size_t nmemb, size_t size);
void *realloc(void *ptr, size_t size);
void qsort(void *base, size_t nmemb, size_t size,
	int (*compar)(const void *, const void *));
