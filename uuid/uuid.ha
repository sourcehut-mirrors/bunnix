// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use bytes;

// A UUID.
export type uuid = [16]u8;

// The length of a UUID in bytes.
export def UUID_LEN: size = 16;

// The length of a UUID in runes when encoded as a string.
export def UUID_STRLEN: size = 36;

// The length of the return value of [[uri]] in runes.
export def UUID_URILEN: size = 45;

// The "nil" UUID, with all bits set to zero.
export const nil: uuid = [0...];

// Returned from [[decode]] if an invalid UUID is observed.
export type invalid = !void;

// Octet offsets of various fields as defined by the RFC.
def TIME_LOW: size = 0;
def TIME_MID: size = 4;
def TIME_HI_AND_VERSION: size = 6;
def CLOCK_SEQ_HI_AND_RESERVED: size = 8;
def CLOCK_SEQ_LOW: size = 9;
def NODE: size = 10;

// Returns true if two UUIDs are equal.
export fn compare(a: uuid, b: uuid) bool = bytes::equal(a, b);
