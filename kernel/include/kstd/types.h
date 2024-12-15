/**
 * Copyright (c) 2024, Jayden Grubb <contact@jaydengrubb.com>
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#pragma once

using u8 = __UINT8_TYPE__;
using u16 = __UINT16_TYPE__;
using u32 = __UINT32_TYPE__;
using u64 = __UINT64_TYPE__;
using usize = __SIZE_TYPE__;
using uptr = __UINTPTR_TYPE__;
using umax = __UINTMAX_TYPE__;
using i8 = __INT8_TYPE__;
using i16 = __INT16_TYPE__;
using i32 = __INT32_TYPE__;
using i64 = __INT64_TYPE__;
using isize = __INTMAX_TYPE__;
using iptr = __INTPTR_TYPE__;
using imax = __INTMAX_TYPE__;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wliteral-suffix"

inline constexpr u64 operator"" KiB(unsigned long long val) {
	return val * 1024;
}

inline constexpr u64 operator"" MiB(unsigned long long val) {
	return val * 1024 * 1024;
}

inline constexpr u64 operator"" GiB(unsigned long long val) {
	return val * 1024 * 1024 * 1024;
}

inline constexpr u64 operator"" TiB(unsigned long long val) {
	return val * 1024 * 1024 * 1024 * 1024;
}

inline constexpr u64 operator"" PiB(unsigned long long val) {
	return val * 1024 * 1024 * 1024 * 1024 * 1024;
}

inline constexpr u64 operator"" KB(unsigned long long val) {
	return val * 1000;
}

inline constexpr u64 operator"" MB(unsigned long long val) {
	return val * 1000 * 1000;
}

inline constexpr u64 operator"" GB(unsigned long long val) {
	return val * 1000 * 1000 * 1000;
}

inline constexpr u64 operator"" TB(unsigned long long val) {
	return val * 1000 * 1000 * 1000 * 1000;
}

inline constexpr u64 operator"" PB(unsigned long long val) {
	return val * 1000 * 1000 * 1000 * 1000 * 1000;
}

#pragma GCC diagnostic pop
