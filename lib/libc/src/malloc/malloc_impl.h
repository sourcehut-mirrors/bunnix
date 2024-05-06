#pragma once

enum {WORD = sizeof(size_t)};

enum {ALIGN = 2};

enum {WASTE = WORD*ALIGN - WORD}; 

enum {BIGBLOCK = (2<<16)*WORD};

enum {BINS = 50};
