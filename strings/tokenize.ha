// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use bytes;
use types;

// The state for a tokenizer.
export type tokenizer = bytes::tokenizer;

// Returns a tokenizer which yields sub-strings tokenized by a delimiter,
// starting at the beginning of the string.
//
// 	let tok = strings::tokenize("hello, my name is drew", " ");
// 	assert(strings::next_token(&tok) as str == "hello,");
// 	assert(strings::next_token(&tok) as str == "my");
// 	assert(strings::next_token(&tok) as str == "name");
// 	assert(strings::remaining_tokens(&tok) == "is drew");
//
// The caller must ensure that 'delim' is not an empty string.
export fn tokenize(s: str, delim: str) tokenizer =
	bytes::tokenize(toutf8(s), toutf8(delim));

// Returns a tokenizer which yields sub-strings tokenized by a delimiter,
// starting at the end of the string and moving backwards with each call
// to [[next_token]].
//
// 	let tok = strings::rtokenize("hello, my name is drew", " ");
// 	assert(strings::next_token(&tok) as str == "drew");
// 	assert(strings::next_token(&tok) as str == "is");
// 	assert(strings::next_token(&tok) as str == "name");
// 	assert(strings::remaining_tokens(&tok) == "hello, my");
//
// The caller must ensure that 'delim' is not an empty string.
export fn rtokenize(s: str, delim: str) tokenizer =
	bytes::rtokenize(toutf8(s), toutf8(delim));

// Returns the next string from a tokenizer, and advances the cursor. Returns
// done if there are no tokens left.
export fn next_token(s: *tokenizer) (str | done) = {
	let s = s: *bytes::tokenizer;
	return match (bytes::next_token(s)) {
	case let b: []u8 =>
		yield fromutf8_unsafe(b);
	case void => yield done;
	};
};

// Same as next_token(), but does not advance the cursor
export fn peek_token(s: *tokenizer) (str | void) = {
	let s = s: *bytes::tokenizer;
	return match (bytes::peek_token(s)) {
	case let b: []u8 =>
		yield fromutf8_unsafe(b);
	case void => void;
	};
};

// Returns the remainder of the string associated with a tokenizer, without doing
// any further tokenization.
export fn remaining_tokens(s: *tokenizer) str = {
	let s = s: *bytes::tokenizer;
	return fromutf8_unsafe(bytes::remaining_tokens(s));
};

@test fn tokenize() void = {
	let tok = tokenize("Hello, my name is drew", " ");
	assert(next_token(&tok) as str == "Hello,");
	assert(next_token(&tok) as str == "my");
	assert(peek_token(&tok) as str == "name");
	assert(next_token(&tok) as str == "name");
	assert(remaining_tokens(&tok) == "is drew");
	assert(peek_token(&tok) as str == "is");
	assert(remaining_tokens(&tok) == "is drew");

	let tok = tokenize("foo", "foo");
	assert(peek_token(&tok) as str == "");
	assert(next_token(&tok) as str == "");
	assert(peek_token(&tok) as str == "");
	assert(next_token(&tok) as str == "");
	assert(peek_token(&tok) is void);
	assert(next_token(&tok) is done);

	let tok = tokenize("", "foo");
	assert(peek_token(&tok) is void);
	assert(next_token(&tok) is done);

	let tok = rtokenize("Hello, my name is drew", " ");
	assert(next_token(&tok) as str == "drew");
	assert(next_token(&tok) as str == "is");
	assert(next_token(&tok) as str == "name");
	assert(remaining_tokens(&tok) == "Hello, my");
	assert(peek_token(&tok) as str == "my");
	assert(remaining_tokens(&tok) == "Hello, my");
};

// Returns a string "cut" along the first instance of a delimiter, returning
// everything up to the delimiter, and everything after the delimiter, in a
// tuple.
//
// 	strings::cut("hello=world=foobar", "=")	// ("hello", "world=foobar")
// 	strings::cut("hello world", "=")	// ("hello world", "")
//
// The return value is borrowed from the 'in' parameter. The caller must ensure
// that 'delim' is not an empty string.
export fn cut(in: str, delim: str) (str, str) = {
	let c = bytes::cut(toutf8(in), toutf8(delim));
	return (fromutf8_unsafe(c.0), fromutf8_unsafe(c.1));
};

// Returns a string "cut" along the last instance of a delimiter, returning
// everything up to the delimiter, and everything after the delimiter, in a
// tuple.
//
// 	strings::rcut("hello=world=foobar", "=")	// ("hello=world", "foobar")
// 	strings::rcut("hello world", "=")	// ("hello world", "")
//
// The return value is borrowed from the 'in' parameter. The caller must ensure
// that 'delim' is not an empty string.
export fn rcut(in: str, delim: str) (str, str) = {
	let c = bytes::rcut(toutf8(in), toutf8(delim));
	return (fromutf8_unsafe(c.0), fromutf8_unsafe(c.1));
};

@test fn cut() void = {
	const sample = cut("hello=world", "=");
	assert(sample.0 == "hello" && sample.1 == "world");
	const sample = cut("hello=world=foobar", "=");
	assert(sample.0 == "hello" && sample.1 == "world=foobar");
	const sample = cut("hello world", "=");
	assert(sample.0 == "hello world" && sample.1 == "");
	const sample = cut("", "=");
	assert(sample.0 == "" && sample.1 == "");

	const sample = rcut("hello=world=foobar", "=");
	assert(sample.0 == "hello=world" && sample.1 == "foobar");
};
